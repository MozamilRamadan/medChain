require('dotenv').config();

const bcrypt = require('bcrypt');
const { connectDB, getPool, closeDB } = require('../src/config/db');

async function seedAdmin() {
    const fullName = process.env.ADMIN_FULL_NAME?.trim();
    const phone = process.env.ADMIN_PHONE?.trim();
    const nationalId = process.env.ADMIN_NATIONAL_ID?.trim();
    const password = process.env.ADMIN_PASSWORD;

    if (!fullName || !phone || !nationalId || !password) {
        throw new Error(
            'Set ADMIN_FULL_NAME, ADMIN_PHONE, ADMIN_NATIONAL_ID and ADMIN_PASSWORD in .env'
        );
    }
    if (password.length < 12) {
        throw new Error('ADMIN_PASSWORD must contain at least 12 characters.');
    }

    await connectDB();
    const pool = getPool();
    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        const existing = await client.query(
            'SELECT "UserId" FROM "Users" WHERE "NationalId" = $1',
            [nationalId]
        );

        if (existing.rowCount) {
            const userId = existing.rows[0].UserId;
            const admin = await client.query(
                `SELECT 1 FROM "UserRoles"
                 WHERE "UserId" = $1 AND "Role" = 'admin'`,
                [userId]
            );

            if (!admin.rowCount) {
                throw new Error(
                    'This National ID belongs to a non-admin account. No role was changed.'
                );
            }

            await client.query('ROLLBACK');
            console.log('This account already has the admin role.');
            return;
        }

        const passwordHash = await bcrypt.hash(password, 12);
        const inserted = await client.query(
            `INSERT INTO "Users" ("FullName", "Phone", "NationalId", "PasswordHash")
             VALUES ($1, $2, $3, $4) RETURNING "UserId"`,
            [fullName, phone, nationalId, passwordHash]
        );

        const userId = inserted.rows[0].UserId;
        await client.query(
            `INSERT INTO "UserRoles" ("UserId", "Role")
             VALUES ($1, 'admin')`,
            [userId]
        );

        await client.query('COMMIT');
        console.log(`Admin account created. UserId: ${userId}`);
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

seedAdmin()
    .catch(error => {
        console.error('Admin seed failed:', error.message);
        process.exitCode = 1;
    })
    .finally(async () => {
        await closeDB();
    });
