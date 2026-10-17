
require('dotenv').config();

const bcrypt = require('bcrypt');
const { sql, connectDB, getPool } = require('../src/config/db');

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
    const transaction = new sql.Transaction(pool);

    try {
        await transaction.begin();

        const check = await transaction.request()
            .input('NationalId', sql.NVarChar(30), nationalId)
            .query(`
                SELECT UserId
                FROM dbo.Users
                WHERE NationalId = @NationalId;
            `);

        let userId;

        if (check.recordset.length > 0) {
            userId = check.recordset[0].UserId;

            const existingAdmin = await transaction.request()
                .input('UserId', sql.Int, userId)
                .query(`
                    SELECT UserRoleId
                    FROM dbo.UserRoles
                    WHERE UserId = @UserId
                      AND Role = N'admin';
                `);

            if (existingAdmin.recordset.length === 0) {
                throw new Error(
                    'This National ID already belongs to a non-admin account. ' +
                    'Refusing to promote it automatically.'
                );
            }

            console.log('This account already has the admin role.');
            await transaction.rollback();
            return;
        }

        const passwordHash = await bcrypt.hash(password, 12);

        const insertedUser = await transaction.request()
            .input('FullName', sql.NVarChar(100), fullName)
            .input('Phone', sql.NVarChar(20), phone)
            .input('NationalId', sql.NVarChar(30), nationalId)
            .input('PasswordHash', sql.NVarChar(255), passwordHash)
            .query(`
                INSERT INTO dbo.Users
                    (FullName, Phone, NationalId, PasswordHash)
                OUTPUT INSERTED.UserId
                VALUES
                    (@FullName, @Phone, @NationalId, @PasswordHash);
            `);

        userId = insertedUser.recordset[0].UserId;

        await transaction.request()
            .input('UserId', sql.Int, userId)
            .input('Role', sql.NVarChar(20), 'admin')
            .query(`
                INSERT INTO dbo.UserRoles (UserId, Role)
                VALUES (@UserId, @Role);
            `);

        await transaction.commit();

        console.log(`Admin account created successfully. UserId: ${userId}`);
    } catch (error) {
        try {
            await transaction.rollback();
        } catch (_) {
            // The transaction may already have been rolled back.
        }
        throw error;
    }
}

seedAdmin()
    .catch(error => {
        console.error('Admin seed failed:', error.message);
        process.exitCode = 1;
    })
    .finally(async () => {
        await sql.close().catch(() => {});
    });
