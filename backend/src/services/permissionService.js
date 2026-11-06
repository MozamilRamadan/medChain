const { getPool } = require('../config/db');

async function requestPermission({ patientId, doctorId }) {
    const pool = getPool();

    const [patient, doctor] = await Promise.all([
        pool.query('SELECT 1 FROM "PatientProfiles" WHERE "PatientId" = $1', [patientId]),
        pool.query('SELECT 1 FROM "DoctorProfiles" WHERE "DoctorId" = $1', [doctorId])
    ]);

    if (!patient.rowCount) throw new Error('Patient not found');
    if (!doctor.rowCount) throw new Error('Doctor not found');

    const existing = await pool.query(
        `SELECT "PermissionId" FROM "Permissions"
         WHERE "PatientId" = $1 AND "DoctorId" = $2
           AND "Status" IN ('pending', 'approved')`,
        [patientId, doctorId]
    );

    if (existing.rowCount) {
        throw new Error('A pending or approved permission already exists');
    }

    const result = await pool.query(
        `INSERT INTO "Permissions" ("PatientId", "DoctorId", "Status")
         VALUES ($1, $2, 'pending')
         RETURNING "PermissionId", "PatientId", "DoctorId", "Status", "RequestedAt"`,
        [patientId, doctorId]
    );

    return result.rows[0];
}

async function getPatientPermissions(patientId) {
    const pool = getPool();
    const result = await pool.query(
        `SELECT
            p."PermissionId", p."PatientId", p."DoctorId",
            p."Status", p."RequestedAt", p."RespondedAt",
            u."FullName" AS "DoctorName",
            u."ProfileImagePath" AS "DoctorProfileImagePath",
            d."LicenseNumber", d."Specialization"
         FROM "Permissions" p
         INNER JOIN "DoctorProfiles" d ON p."DoctorId" = d."DoctorId"
         INNER JOIN "Users" u ON d."UserId" = u."UserId"
         WHERE p."PatientId" = $1
         ORDER BY p."RequestedAt" DESC`,
        [patientId]
    );
    return result.rows;
}

async function updatePermissionStatus({ permissionId, status }) {
    if (!['approved', 'rejected'].includes(status)) {
        throw new Error('Invalid permission status');
    }

    const pool = getPool();
    const result = await pool.query(
        `UPDATE "Permissions"
         SET "Status" = $1, "RespondedAt" = CURRENT_TIMESTAMP
         WHERE "PermissionId" = $2
         RETURNING "PermissionId", "PatientId", "DoctorId",
                   "Status", "RequestedAt", "RespondedAt"`,
        [status, permissionId]
    );

    if (!result.rowCount) throw new Error('Permission not found');
    return result.rows[0];
}

async function getDoctorApprovedPatients(doctorId) {
    const pool = getPool();
    const result = await pool.query(
        `SELECT p."PatientId", u."FullName", u."Phone",
                u."ProfileImagePath" AS "ProfileImagePath"
         FROM "Permissions" p
         INNER JOIN "PatientProfiles" pp ON p."PatientId" = pp."PatientId"
         INNER JOIN "Users" u ON pp."UserId" = u."UserId"
         WHERE p."DoctorId" = $1 AND p."Status" = 'approved'
         ORDER BY u."FullName"`,
        [doctorId]
    );
    return result.rows;
}

async function revokePermission({ permissionId, userId }) {
    const pool = getPool();
    const result = await pool.query(
        `UPDATE "Permissions" p
         SET "Status" = 'revoked', "RespondedAt" = CURRENT_TIMESTAMP
         FROM "PatientProfiles" pp
         WHERE pp."PatientId" = p."PatientId"
           AND p."PermissionId" = $1
           AND pp."UserId" = $2
           AND p."Status" = 'approved'
         RETURNING p."PermissionId", p."PatientId", p."DoctorId",
                   p."Status", p."RespondedAt"`,
        [permissionId, userId]
    );

    if (!result.rowCount) {
        throw new Error('Approved permission not found for this patient');
    }
    return result.rows[0];
}

module.exports = {
    requestPermission,
    getPatientPermissions,
    updatePermissionStatus,
    getDoctorApprovedPatients,
    revokePermission
};
