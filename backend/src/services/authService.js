const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { getPool } = require('../config/db');

async function registerUser({
    fullName, phone, nationalId, password, roles,
    licenseNumber, specialization
}) {
    if (!Array.isArray(roles) || roles.length === 0) {
        throw new Error('At least one role is required');
    }

    const allowedRoles = ['patient', 'doctor'];
    if (roles.some(role => !allowedRoles.includes(role))) {
        throw new Error('Invalid role');
    }

    const uniqueRoles = [...new Set(roles)];

    if (uniqueRoles.includes('doctor') &&
        (!licenseNumber || !licenseNumber.trim())) {
        throw new Error('License number is required for doctor registration');
    }

    const pool = getPool();
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const existing = await client.query(
            'SELECT "UserId" FROM "Users" WHERE "NationalId" = $1',
            [nationalId]
        );

        if (existing.rowCount) {
            throw new Error('An account with this National ID already exists');
        }

        const passwordHash = await bcrypt.hash(password, 12);

        const inserted = await client.query(
            `INSERT INTO "Users"
                ("FullName", "Phone", "NationalId", "PasswordHash")
             VALUES ($1, $2, $3, $4)
             RETURNING "UserId"`,
            [fullName, phone, nationalId, passwordHash]
        );

        const userId = inserted.rows[0].UserId;

        if (uniqueRoles.includes('patient')) {
            await client.query(
                'INSERT INTO "PatientProfiles" ("UserId") VALUES ($1)',
                [userId]
            );
        }

        if (uniqueRoles.includes('doctor')) {
            await client.query(
                `INSERT INTO "DoctorProfiles"
                    ("UserId", "LicenseNumber", "Specialization")
                 VALUES ($1, $2, $3)`,
                [userId, licenseNumber.trim(), specialization?.trim() || null]
            );
        }

        await client.query('COMMIT');
        return { userId, roles: uniqueRoles };
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

async function loginUser({ nationalId, password }) {
    const pool = getPool();

    const result = await pool.query(
        `SELECT "UserId", "FullName", "Phone", "NationalId", "PasswordHash"
         FROM "Users"
         WHERE "NationalId" = $1`,
        [nationalId]
    );

    if (!result.rowCount) {
        throw new Error('Invalid National ID or password');
    }

    const user = result.rows[0];

    // Keep existing password hashes unchanged. Never reset hashes during migration.
    const passwordValid = await bcrypt.compare(password, user.PasswordHash);
    if (!passwordValid) {
        throw new Error('Invalid National ID or password');
    }

    const rolesResult = await pool.query(
        `SELECT 'patient' AS "Role", "PatientId" AS "RoleId"
           FROM "PatientProfiles" WHERE "UserId" = $1
         UNION ALL
         SELECT 'doctor' AS "Role", "DoctorId" AS "RoleId"
           FROM "DoctorProfiles" WHERE "UserId" = $1
         UNION ALL
         SELECT "Role", "UserId" AS "RoleId"
           FROM "UserRoles" WHERE "UserId" = $1`,
        [user.UserId]
    );

    if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET is not configured');
    }

    const token = jwt.sign(
        { userId: user.UserId },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
    );

    return {
        token,
        user: {
            userId: user.UserId,
            fullName: user.FullName,
            phone: user.Phone,
            nationalId: user.NationalId,
            roles: rolesResult.rows
        }
    };
}

module.exports = { registerUser, loginUser };
