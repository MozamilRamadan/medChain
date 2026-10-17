const { sql, getPool } = require('../config/db');


async function requestPermission({
    patientId,
    doctorId
}) {
    const pool = getPool();

    // Check if patient exists
    const patientResult = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .query(`
            SELECT PatientId
            FROM PatientProfiles
            WHERE PatientId = @PatientId
        `);

    if (patientResult.recordset.length === 0) {
        throw new Error('Patient not found');
    }

    // Check if doctor exists
    const doctorResult = await pool
        .request()
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            SELECT DoctorId
            FROM DoctorProfiles
            WHERE DoctorId = @DoctorId
        `);

    if (doctorResult.recordset.length === 0) {
        throw new Error('Doctor not found');
    }

    // Check existing pending/approved permission
    const existingResult = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            SELECT
                PermissionId,
                Status
            FROM Permissions
            WHERE PatientId = @PatientId
              AND DoctorId = @DoctorId
              AND Status IN ('pending', 'approved')
        `);

    if (existingResult.recordset.length > 0) {
        throw new Error(
            'A pending or approved permission already exists'
        );
    }

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            INSERT INTO Permissions
            (
                PatientId,
                DoctorId,
                Status
            )
            OUTPUT
                INSERTED.PermissionId,
                INSERTED.PatientId,
                INSERTED.DoctorId,
                INSERTED.Status,
                INSERTED.RequestedAt
            VALUES
            (
                @PatientId,
                @DoctorId,
                'pending'
            )
        `);

    return result.recordset[0];
}


async function getPatientPermissions(patientId) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('PatientId', sql.Int, patientId)
        .query(`
            SELECT
                p.PermissionId,
                p.PatientId,
                p.DoctorId,
                p.Status,
                p.RequestedAt,
                p.RespondedAt,

                u.FullName AS DoctorName,
                d.LicenseNumber,
                d.Specialization

            FROM Permissions p

            INNER JOIN DoctorProfiles d
                ON p.DoctorId = d.DoctorId

            INNER JOIN Users u
                ON d.UserId = u.UserId

            WHERE p.PatientId = @PatientId

            ORDER BY p.RequestedAt DESC
        `);

    return result.recordset;
}


async function updatePermissionStatus({
    permissionId,
    status
}) {
    const allowedStatuses = [
        'approved',
        'rejected'
    ];

    if (!allowedStatuses.includes(status)) {
        throw new Error('Invalid permission status');
    }

    const pool = getPool();

    const result = await pool
        .request()
        .input('PermissionId', sql.Int, permissionId)
        .input('Status', sql.NVarChar(20), status)
        .query(`
            UPDATE Permissions

            SET
                Status = @Status,
                RespondedAt = SYSDATETIME()

            OUTPUT
                INSERTED.PermissionId,
                INSERTED.PatientId,
                INSERTED.DoctorId,
                INSERTED.Status,
                INSERTED.RequestedAt,
                INSERTED.RespondedAt

            WHERE PermissionId = @PermissionId
        `);

    if (result.recordset.length === 0) {
        throw new Error('Permission not found');
    }

    return result.recordset[0];
}

async function getDoctorApprovedPatients(doctorId) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('DoctorId', sql.Int, doctorId)
        .query(`
            SELECT
                p.PatientId,
                u.FullName,
                u.Phone
            FROM Permissions p

            INNER JOIN PatientProfiles pp
                ON p.PatientId = pp.PatientId

            INNER JOIN Users u
                ON pp.UserId = u.UserId

            WHERE p.DoctorId = @DoctorId
              AND p.Status = 'approved'

            ORDER BY u.FullName
        `);

    return result.recordset;
}

async function revokePermission({ permissionId, userId }) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('PermissionId', sql.Int, permissionId)
        .input('UserId', sql.Int, userId)
        .query(`
            UPDATE p
            SET
                Status = 'revoked',
                RespondedAt = SYSDATETIME()
            OUTPUT
                INSERTED.PermissionId,
                INSERTED.PatientId,
                INSERTED.DoctorId,
                INSERTED.Status,
                INSERTED.RespondedAt
            FROM dbo.Permissions AS p
            INNER JOIN dbo.PatientProfiles AS pp
                ON pp.PatientId = p.PatientId
            WHERE p.PermissionId = @PermissionId
              AND pp.UserId = @UserId
              AND p.Status = 'approved';
        `);

    if (result.recordset.length === 0) {
        throw new Error(
            'Approved permission not found for this patient'
        );
    }

    return result.recordset[0];
}

module.exports = {
    requestPermission,
    getPatientPermissions,
    updatePermissionStatus,
    getDoctorApprovedPatients,
    revokePermission
};