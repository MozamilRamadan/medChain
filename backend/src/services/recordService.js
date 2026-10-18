
const { sql, getPool } = require('../config/db');

// Check whether doctor has approved permission.
async function checkDoctorPermission(patientId, doctorId) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            SELECT PermissionId
            FROM dbo.Permissions
            WHERE PatientId = @PatientId
              AND DoctorId = @DoctorId
              AND Status = 'approved'
        `);

    return result.recordset.length > 0;
}

// Save medical record in SQL Server.
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
            INSERT INTO dbo.MedicalRecords
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

// Get patient's medical records.
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
                d.Specialization
            FROM dbo.MedicalRecords AS r
            INNER JOIN dbo.DoctorProfiles AS d
                ON r.DoctorId = d.DoctorId
            INNER JOIN dbo.Users AS u
                ON d.UserId = u.UserId
            WHERE r.PatientId = @PatientId
            ORDER BY r.CreatedAt DESC
        `);

    return result.recordset;
}

// Get records for a doctor only while approved permission exists.
async function getDoctorRecords({ doctorId, patientId }) {
    const hasPermission = await checkDoctorPermission(
        patientId,
        doctorId
    );

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
                r.CreatedAt
            FROM dbo.MedicalRecords AS r
            WHERE r.PatientId = @PatientId
              AND r.DoctorId = @DoctorId
            ORDER BY r.CreatedAt DESC
        `);

    return result.recordset;
}

// Delete a record only if the authenticated user is its patient
// or the doctor who created it.
async function deleteMedicalRecord({ recordId, userId }) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('RecordId', sql.Int, recordId)
        .input('UserId', sql.Int, userId)
        .query(`
            DELETE r
            OUTPUT DELETED.RecordId
            FROM dbo.MedicalRecords AS r
            WHERE r.RecordId = @RecordId
              AND (
                  EXISTS (
                      SELECT 1
                      FROM dbo.PatientProfiles AS pp
                      WHERE pp.PatientId = r.PatientId
                        AND pp.UserId = @UserId
                  )
                  OR EXISTS (
                      SELECT 1
                      FROM dbo.DoctorProfiles AS dp
                      WHERE dp.DoctorId = r.DoctorId
                        AND dp.UserId = @UserId
                  )
              )
        `);

    if (result.recordset.length === 0) {
        const error = new Error(
            'Record not found or you do not have permission to delete it'
        );

        error.code = 'RECORD_NOT_FOUND_OR_FORBIDDEN';
        throw error;
    }

    return result.recordset[0];
}

module.exports = {
    checkDoctorPermission,
    saveMedicalRecord,
    getPatientRecords,
    getDoctorRecords,
    deleteMedicalRecord
};
