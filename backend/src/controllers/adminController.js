
const { sql, getPool } = require('../config/db');

// --------------------------------------------------
// GET ALL USERS
// --------------------------------------------------
async function getUsers(req, res) {
    try {
        const pool = await getPool();

        const result = await pool.request().query(`
            SELECT
                u.UserId,
                u.FullName,
                u.Phone,
                u.NationalId,
                u.CreatedAt,

                CAST(
                    CASE WHEN EXISTS (
                        SELECT 1
                        FROM dbo.PatientProfiles pp
                        WHERE pp.UserId = u.UserId
                    )
                    THEN 1 ELSE 0 END
                AS bit) AS IsPatient,

                CAST(
                    CASE WHEN EXISTS (
                        SELECT 1
                        FROM dbo.DoctorProfiles dp
                        WHERE dp.UserId = u.UserId
                    )
                    THEN 1 ELSE 0 END
                AS bit) AS IsDoctor,

                CAST(
                    CASE WHEN EXISTS (
                        SELECT 1
                        FROM dbo.UserRoles ur
                        WHERE ur.UserId = u.UserId
                          AND ur.Role = N'admin'
                    )
                    THEN 1 ELSE 0 END
                AS bit) AS IsAdmin

            FROM dbo.Users u
            ORDER BY u.UserId;
        `);

        return res.json({
            success: true,
            count: result.recordset.length,
            users: result.recordset
        });
    } catch (error) {
        console.error('Get users error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve users'
        });
    }
}

// --------------------------------------------------
// GRANT OR REMOVE ADMIN ROLE
// --------------------------------------------------
async function setAdminRole(req, res) {
    const userId = Number(req.params.userId);
    const { enabled } = req.body;

    if (!Number.isSafeInteger(userId) || userId <= 0) {
        return res.status(400).json({
            success: false,
            message: 'Invalid user ID'
        });
    }

    if (typeof enabled !== 'boolean') {
        return res.status(400).json({
            success: false,
            message: 'The enabled field must be true or false'
        });
    }

    let transaction;
    let transactionStarted = false;

    try {
        const pool = await getPool();

        transaction = new sql.Transaction(pool);

        await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);
        transactionStarted = true;

        const userResult = await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                SELECT UserId
                FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId;
            `);

        if (userResult.recordset.length === 0) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const roleResult = await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                SELECT UserRoleId
                FROM dbo.UserRoles WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId
                  AND Role = N'admin';
            `);

        const alreadyAdmin = roleResult.recordset.length > 0;

        if (enabled && alreadyAdmin) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(409).json({
                success: false,
                message: 'This user is already an administrator'
            });
        }

        if (!enabled && !alreadyAdmin) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(409).json({
                success: false,
                message: 'This user is not an administrator'
            });
        }

        if (enabled) {
            await transaction.request()
                .input('UserId', sql.Int, userId)
                .query(`
                    INSERT INTO dbo.UserRoles (UserId, Role)
                    VALUES (@UserId, N'admin');
                `);
        } else {
            const adminCountResult = await transaction.request().query(`
                SELECT COUNT(DISTINCT UserId) AS AdminCount
                FROM dbo.UserRoles WITH (UPDLOCK, HOLDLOCK)
                WHERE Role = N'admin';
            `);

            const adminCount =
                adminCountResult.recordset[0].AdminCount;

            if (adminCount <= 1) {
                await transaction.rollback();
                transactionStarted = false;

                return res.status(409).json({
                    success: false,
                    message: 'Cannot remove the last administrator'
                });
            }

            await transaction.request()
                .input('UserId', sql.Int, userId)
                .query(`
                    DELETE FROM dbo.UserRoles
                    WHERE UserId = @UserId
                      AND Role = N'admin';
                `);
        }

        await transaction.commit();
        transactionStarted = false;

        return res.json({
            success: true,
            message: enabled
                ? 'Administrator role granted successfully'
                : 'Administrator role removed successfully'
        });
    } catch (error) {
        if (transactionStarted) {
            try {
                await transaction.rollback();
            } catch (rollbackError) {
                console.error('Admin-role rollback error:', rollbackError);
            }
        }

        console.error('Set admin role error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to update administrator role'
        });
    }
}

// --------------------------------------------------
// REMOVE PATIENT OR DOCTOR PROFILE
// --------------------------------------------------
async function removeProfile(req, res, profileType) {
    const userId = Number(req.params.userId);

    if (!Number.isSafeInteger(userId) || userId <= 0) {
        return res.status(400).json({
            success: false,
            message: 'Invalid user ID'
        });
    }

    const isPatient = profileType === 'patient';

    const profileTable = isPatient
        ? 'dbo.PatientProfiles'
        : 'dbo.DoctorProfiles';

    const profileIdColumn = isPatient
        ? 'PatientId'
        : 'DoctorId';

    const recordProfileColumn = isPatient
        ? 'PatientId'
        : 'DoctorId';

    const profileName = isPatient ? 'patient' : 'doctor';

    let transaction;
    let transactionStarted = false;

    try {
        const pool = await getPool();

        transaction = new sql.Transaction(pool);

        await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);
        transactionStarted = true;

        const userResult = await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                SELECT UserId
                FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId;
            `);

        if (userResult.recordset.length === 0) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const profileResult = await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                SELECT ${profileIdColumn} AS ProfileId
                FROM ${profileTable} WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId;
            `);

        if (profileResult.recordset.length === 0) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(404).json({
                success: false,
                message: `This user does not have a ${profileName} profile`
            });
        }

        const profileId = profileResult.recordset[0].ProfileId;

        const recordsResult = await transaction.request()
            .input('ProfileId', sql.Int, profileId)
            .query(`
                SELECT TOP (1) RecordId
                FROM dbo.MedicalRecords WITH (UPDLOCK, HOLDLOCK)
                WHERE ${recordProfileColumn} = @ProfileId;
            `);

        if (recordsResult.recordset.length > 0) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(409).json({
                success: false,
                message:
                    `Cannot remove this ${profileName} profile because medical records depend on it. Delete the entire account if that is intended.`
            });
        }

        // Remove permission relationships before the profile.
        await transaction.request()
            .input('ProfileId', sql.Int, profileId)
            .query(`
                DELETE FROM dbo.Permissions
                WHERE ${recordProfileColumn} = @ProfileId;
            `);

        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM ${profileTable}
                WHERE UserId = @UserId;
            `);

        await transaction.commit();
        transactionStarted = false;

        return res.json({
            success: true,
            message: `${profileName.charAt(0).toUpperCase() + profileName.slice(1)} profile removed successfully`
        });
    } catch (error) {
        if (transactionStarted) {
            try {
                await transaction.rollback();
            } catch (rollbackError) {
                console.error('Profile-removal rollback error:', rollbackError);
            }
        }

        console.error(`Remove ${profileName} profile error:`, error);

        return res.status(500).json({
            success: false,
            message: `Failed to remove ${profileName} profile`
        });
    }
}

async function removePatientProfile(req, res) {
    return removeProfile(req, res, 'patient');
}

async function removeDoctorProfile(req, res) {
    return removeProfile(req, res, 'doctor');
}

// --------------------------------------------------
// DELETE COMPLETE USER ACCOUNT
// --------------------------------------------------
async function deleteUserAccount(req, res) {
    const userId = Number(req.params.userId);
    const currentUserId = req.user.userId;

    if (!Number.isSafeInteger(userId) || userId <= 0) {
        return res.status(400).json({
            success: false,
            message: 'Invalid user ID'
        });
    }

    // Never allow an administrator to delete their own account here.
    if (userId === currentUserId) {
        return res.status(403).json({
            success: false,
            message: 'You cannot delete your own account from the admin dashboard'
        });
    }

    let transaction;
    let transactionStarted = false;

    try {
        const pool = await getPool();

        transaction = new sql.Transaction(pool);

        await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);
        transactionStarted = true;

        const userResult = await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                SELECT UserId
                FROM dbo.Users WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId;
            `);

        if (userResult.recordset.length === 0) {
            await transaction.rollback();
            transactionStarted = false;

            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // If the target is an administrator, protect the last admin.
        const targetAdminResult = await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                SELECT UserRoleId
                FROM dbo.UserRoles WITH (UPDLOCK, HOLDLOCK)
                WHERE UserId = @UserId
                  AND Role = N'admin';
            `);

        if (targetAdminResult.recordset.length > 0) {
            const adminCountResult = await transaction.request().query(`
                SELECT COUNT(DISTINCT UserId) AS AdminCount
                FROM dbo.UserRoles WITH (UPDLOCK, HOLDLOCK)
                WHERE Role = N'admin';
            `);

            if (adminCountResult.recordset[0].AdminCount <= 1) {
                await transaction.rollback();
                transactionStarted = false;

                return res.status(409).json({
                    success: false,
                    message: 'Cannot delete the last administrator'
                });
            }
        }

        // Remove permissions involving either profile owned by this user.
        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM dbo.Permissions
                WHERE PatientId IN (
                    SELECT PatientId
                    FROM dbo.PatientProfiles
                    WHERE UserId = @UserId
                )
                OR DoctorId IN (
                    SELECT DoctorId
                    FROM dbo.DoctorProfiles
                    WHERE UserId = @UserId
                );
            `);

        // Delete SQL medical records involving this user's patient
        // or doctor profile so the profile foreign keys are satisfied.
        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM dbo.MedicalRecords
                WHERE PatientId IN (
                    SELECT PatientId
                    FROM dbo.PatientProfiles
                    WHERE UserId = @UserId
                )
                OR DoctorId IN (
                    SELECT DoctorId
                    FROM dbo.DoctorProfiles
                    WHERE UserId = @UserId
                );
            `);

        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM dbo.PatientProfiles
                WHERE UserId = @UserId;
            `);

        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM dbo.DoctorProfiles
                WHERE UserId = @UserId;
            `);

        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM dbo.UserRoles
                WHERE UserId = @UserId;
            `);

        await transaction.request()
            .input('UserId', sql.Int, userId)
            .query(`
                DELETE FROM dbo.Users
                WHERE UserId = @UserId;
            `);

        await transaction.commit();
        transactionStarted = false;

        return res.json({
            success: true,
            message: 'User account and related SQL records deleted successfully'
        });
    } catch (error) {
        if (transactionStarted) {
            try {
                await transaction.rollback();
            } catch (rollbackError) {
                console.error('Account-deletion rollback error:', rollbackError);
            }
        }

        console.error('Delete user account error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete user account'
        });
    }
}

module.exports = {
    getUsers,
    setAdminRole,
    removePatientProfile,
    removeDoctorProfile,
    deleteUserAccount
};
