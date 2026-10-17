const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { sql, getPool } = require('../config/db');

async function registerUser({
    fullName,
    phone,
    nationalId,
    password,
    roles,
    licenseNumber,
    specialization
}) {
    if (!Array.isArray(roles) || roles.length === 0) {
        throw new Error('At least one role is required');
    }

    const allowedRoles = ['patient', 'doctor'];

    for (const role of roles) {
        if (!allowedRoles.includes(role)) {
            throw new Error(`Invalid role: ${role}`);
        }
    }

    const uniqueRoles = [...new Set(roles)];

    const pool = getPool();

    const existingUser = await pool
        .request()
        .input('NationalId', sql.NVarChar(30), nationalId)
        .query(`
            SELECT UserId
            FROM Users
            WHERE NationalId = @NationalId
        `);

    if (existingUser.recordset.length > 0) {
        throw new Error(
            'An account with this National ID already exists'
        );
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const transaction = new sql.Transaction(pool);

    try {
        await transaction.begin();

        const userResult = await new sql.Request(transaction)
            .input('FullName', sql.NVarChar(100), fullName)
            .input('Phone', sql.NVarChar(20), phone)
            .input('NationalId', sql.NVarChar(30), nationalId)
            .input('PasswordHash', sql.NVarChar(255), passwordHash)
            .query(`
                INSERT INTO Users
                (
                    FullName,
                    Phone,
                    NationalId,
                    PasswordHash
                )
                OUTPUT INSERTED.UserId
                VALUES
                (
                    @FullName,
                    @Phone,
                    @NationalId,
                    @PasswordHash
                )
            `);

        const userId = userResult.recordset[0].UserId;

        if (uniqueRoles.includes('patient')) {
            await new sql.Request(transaction)
                .input('UserId', sql.Int, userId)
                .query(`
                    INSERT INTO PatientProfiles
                    (
                        UserId
                    )
                    VALUES
                    (
                        @UserId
                    )
                `);
        }

        if (uniqueRoles.includes('doctor')) {
            if (!licenseNumber || licenseNumber.trim().length === 0) {
                throw new Error(
                    'License number is required for doctor registration'
                );
            }

            await new sql.Request(transaction)
                .input('UserId', sql.Int, userId)
                .input(
                    'LicenseNumber',
                    sql.NVarChar(50),
                    licenseNumber.trim()
                )
                .input(
                    'Specialization',
                    sql.NVarChar(100),
                    specialization?.trim() || null
                )
                .query(`
                    INSERT INTO DoctorProfiles
                    (
                        UserId,
                        LicenseNumber,
                        Specialization
                    )
                    VALUES
                    (
                        @UserId,
                        @LicenseNumber,
                        @Specialization
                    )
                `);
        }

        await transaction.commit();

        return {
            userId,
            roles: uniqueRoles
        };

    } catch (error) {
        await transaction.rollback();
        throw error;
    }
}


async function loginUser({
    nationalId,
    password
}) {
    const pool = getPool();

    const result = await pool
        .request()
        .input('NationalId', sql.NVarChar(30), nationalId)
        .query(`
            SELECT
                UserId,
                FullName,
                Phone,
                NationalId,
                PasswordHash
            FROM Users
            WHERE NationalId = @NationalId
        `);

    if (result.recordset.length === 0) {
        throw new Error(
            'Invalid National ID or password'
        );
    }

    const user = result.recordset[0];

    const passwordValid = await bcrypt.compare(
        password,
        user.PasswordHash
    );

    if (!passwordValid) {
        throw new Error(
            'Invalid National ID or password'
        );
    }

        
    const rolesResult = await pool
        .request()
        .input('UserId', sql.Int, user.UserId)
        .query(`
            SELECT
                'patient' AS Role,
                PatientId AS RoleId
            FROM PatientProfiles
            WHERE UserId = @UserId

            UNION ALL

            SELECT
                'doctor' AS Role,
                DoctorId AS RoleId
            FROM DoctorProfiles
            WHERE UserId = @UserId

            UNION ALL

            SELECT
                Role,
                UserId AS RoleId
            FROM UserRoles
            WHERE UserId = @UserId
        `);

    const roles = rolesResult.recordset;

    const token = jwt.sign(
        {
            userId: user.UserId
        },
        process.env.JWT_SECRET,
        {
            expiresIn: '7d'
        }
    );

    return {
        token,

        user: {
            userId: user.UserId,
            fullName: user.FullName,
            phone: user.Phone,
            nationalId: user.NationalId,
            roles
        }
    };
}


module.exports = {
    registerUser,
    loginUser
};