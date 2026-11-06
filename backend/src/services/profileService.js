const { getPool } = require('../config/db');

async function getMyProfile(userId) {
    const pool = getPool();

    const result = await pool.query(
        `SELECT
            u."UserId" AS "userId",
            u."FullName" AS "fullName",
            u."Phone" AS "phone",
            u."NationalId" AS "nationalId",
            u."ProfileImagePath" AS "profileImagePath",
            p."PatientId" AS "patientId",
            d."DoctorId" AS "doctorId",
            d."LicenseNumber" AS "licenseNumber",
            d."Specialization" AS "specialization"
         FROM "Users" u
         LEFT JOIN "PatientProfiles" p ON p."UserId" = u."UserId"
         LEFT JOIN "DoctorProfiles" d ON d."UserId" = u."UserId"
         WHERE u."UserId" = $1`,
        [userId]
    );

    if (!result.rowCount) throw new Error('User not found');

    const rolesResult = await pool.query(
        'SELECT "Role" FROM "UserRoles" WHERE "UserId" = $1',
        [userId]
    );

    return {
        ...result.rows[0],
        roles: rolesResult.rows.map(row => row.Role)
    };
}

async function updateMyProfile(userId, { fullName, phone }) {
    if (!fullName?.trim()) throw new Error('Full name is required');
    if (!phone?.trim()) throw new Error('Phone is required');

    const pool = getPool();
    const result = await pool.query(
        `UPDATE "Users"
         SET "FullName" = $1, "Phone" = $2
         WHERE "UserId" = $3`,
        [fullName.trim(), phone.trim(), userId]
    );

    if (!result.rowCount) throw new Error('User not found');
    return getMyProfile(userId);
}

async function updateProfileImage(userId, imagePath) {
    const pool = getPool();
    const result = await pool.query(
        `UPDATE "Users" SET "ProfileImagePath" = $1
         WHERE "UserId" = $2`,
        [imagePath, userId]
    );

    if (!result.rowCount) throw new Error('User not found');
    return getMyProfile(userId);
}

module.exports = { getMyProfile, updateMyProfile, updateProfileImage };
