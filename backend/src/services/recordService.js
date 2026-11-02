
const { sql, getPool } = require('../config/db');

// Check whether doctor has approved permission
async function checkDoctorPermission(patientId, doctorId) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            SELECT PermissionId
            FROM Permissions
            WHERE PatientId = @PatientId
              AND DoctorId = @DoctorId
              AND Status = 'approved'
        `);

    return result.recordset.length > 0;
}

// Save medical record in SQL Server
async function saveMedicalRecord({
    patientId,
    doctorId,
    diagnosis,
    notes,
    ipfsCID,
    blockchainRecordId
}) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .input('DoctorId', sql.Int, doctorId)
        .input('Diagnosis', sql.NVarChar(500), diagnosis)
        .input('Notes', sql.NVarChar(sql.MAX), notes || null)
        .input('IpfsCID', sql.NVarChar(100), ipfsCID || null)
        .input(
            'BlockchainRecordId',
            sql.NVarChar(100),
            blockchainRecordId || null
        )
        .query(`
            INSERT INTO MedicalRecords
            (
                PatientId,
                DoctorId,
                Diagnosis,
                Notes,
                IpfsCID,
                BlockchainRecordId
            )
            OUTPUT
                INSERTED.RecordId,
                INSERTED.PatientId,
                INSERTED.DoctorId,
                INSERTED.Diagnosis,
                INSERTED.Notes,
                INSERTED.IpfsCID,
                INSERTED.BlockchainRecordId,
                INSERTED.CreatedAt
            VALUES
            (
                @PatientId,
                @DoctorId,
                @Diagnosis,
                @Notes,
                @IpfsCID,
                @BlockchainRecordId
            )
        `);

    return result.recordset[0];
}

// Get patient's records from SQL Server
async function getPatientRecords(patientId) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .query(`
            SELECT
                r.RecordId,
                r.PatientId,
                r.DoctorId,
                r.Diagnosis,
                r.Notes,
                r.IpfsCID,
                r.BlockchainRecordId,
                r.CreatedAt,

                u.FullName AS DoctorName,
                u.ProfileImagePath AS DoctorProfileImagePath,
                d.Specialization

            FROM MedicalRecords r

            INNER JOIN DoctorProfiles d
                ON r.DoctorId = d.DoctorId

            INNER JOIN Users u
                ON d.UserId = u.UserId

            WHERE r.PatientId = @PatientId

            ORDER BY r.CreatedAt DESC
        `);

    return result.recordset;
}

// Get records for doctor after checking permission
async function getDoctorRecords({
    doctorId,
    patientId
}) {
    const hasPermission =
        await checkDoctorPermission(patientId, doctorId);

    if (!hasPermission) {
        throw new Error(
            'Doctor does not have approved permission'
        );
    }

    const pool = getPool();

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            SELECT
                r.RecordId,
                r.PatientId,
                r.DoctorId,
                r.Diagnosis,
                r.Notes,
                r.IpfsCID,
                r.BlockchainRecordId,
                r.CreatedAt,

                pu.FullName AS PatientName,
                pu.ProfileImagePath AS PatientProfileImagePath

            FROM MedicalRecords r

            INNER JOIN PatientProfiles pp
                ON r.PatientId = pp.PatientId

            INNER JOIN Users pu
                ON pp.UserId = pu.UserId

            WHERE r.PatientId = @PatientId
              AND r.DoctorId = @DoctorId

            ORDER BY r.CreatedAt DESC
        `);

    return result.recordset;
}

module.exports = {
    checkDoctorPermission,
    saveMedicalRecord,
    getPatientRecords,
    getDoctorRecords
};
