const { getPool } = require('../config/db');

async function getUsers(req, res) {
    try {
        const pool = getPool();
        const result = await pool.query(`
            SELECT
                u."UserId", u."FullName", u."Phone", u."NationalId", u."CreatedAt",
                EXISTS (SELECT 1 FROM "PatientProfiles" pp WHERE pp."UserId" = u."UserId") AS "IsPatient",
                EXISTS (SELECT 1 FROM "DoctorProfiles" dp WHERE dp."UserId" = u."UserId") AS "IsDoctor",
                EXISTS (
                    SELECT 1 FROM "UserRoles" ur
                    WHERE ur."UserId" = u."UserId" AND ur."Role" = 'admin'
                ) AS "IsAdmin"
            FROM "Users" u
            ORDER BY u."UserId"
        `);
        return res.json({ success: true, count: result.rowCount, users: result.rows });
    } catch (error) {
        console.error('Get users error:', error);
        return res.status(500).json({ success: false, message: 'Failed to retrieve users' });
    }
}

async function setAdminRole(req, res) {
    const userId = Number(req.params.userId);
    const { enabled } = req.body;

    if (!Number.isSafeInteger(userId) || userId <= 0) {
        return res.status(400).json({ success: false, message: 'Invalid user ID' });
    }
    if (typeof enabled !== 'boolean') {
        return res.status(400).json({ success: false, message: 'The enabled field must be true or false' });
    }

    const pool = getPool();
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        const user = await client.query(
            'SELECT "UserId" FROM "Users" WHERE "UserId" = $1 FOR UPDATE',
            [userId]
        );
        if (!user.rowCount) {
            await client.query('ROLLBACK');
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        const role = await client.query(
            `SELECT 1 FROM "UserRoles" WHERE "UserId" = $1 AND "Role" = 'admin'`,
            [userId]
        );
        const alreadyAdmin = role.rowCount > 0;

        if (enabled === alreadyAdmin) {
            await client.query('ROLLBACK');
            return res.status(409).json({
                success: false,
                message: enabled ? 'This user is already an administrator' : 'This user is not an administrator'
            });
        }

        if (enabled) {
            await client.query(
                `INSERT INTO "UserRoles" ("UserId", "Role") VALUES ($1, 'admin')`,
                [userId]
            );
        } else {
            const count = await client.query(
                `SELECT COUNT(DISTINCT "UserId")::int AS "AdminCount"
                 FROM "UserRoles" WHERE "Role" = 'admin'`
            );
            if (count.rows[0].AdminCount <= 1) {
                await client.query('ROLLBACK');
                return res.status(409).json({ success: false, message: 'Cannot remove the last administrator' });
            }
            await client.query(
                `DELETE FROM "UserRoles" WHERE "UserId" = $1 AND "Role" = 'admin'`,
                [userId]
            );
        }

        await client.query('COMMIT');
        return res.json({
            success: true,
            message: enabled ? 'Administrator role granted successfully' : 'Administrator role removed successfully'
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Set admin role error:', error);
        return res.status(500).json({ success: false, message: 'Failed to update administrator role' });
    } finally {
        client.release();
    }
}

async function removeProfile(req, res, profileType) {
    const userId = Number(req.params.userId);
    if (!Number.isSafeInteger(userId) || userId <= 0) {
        return res.status(400).json({ success: false, message: 'Invalid user ID' });
    }

    const isPatient = profileType === 'patient';
    const profileTable = isPatient ? '"PatientProfiles"' : '"DoctorProfiles"';
    const profileIdColumn = isPatient ? '"PatientId"' : '"DoctorId"';
    const recordColumn = isPatient ? '"PatientId"' : '"DoctorId"';
    const label = isPatient ? 'patient' : 'doctor';

    const pool = getPool();
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        const user = await client.query(
            'SELECT "UserId" FROM "Users" WHERE "UserId" = $1 FOR UPDATE',
            [userId]
        );
        if (!user.rowCount) {
            await client.query('ROLLBACK');
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        const profile = await client.query(
            `SELECT ${profileIdColumn} AS "ProfileId"
             FROM ${profileTable} WHERE "UserId" = $1 FOR UPDATE`,
            [userId]
        );
        if (!profile.rowCount) {
            await client.query('ROLLBACK');
            return res.status(404).json({ success: false, message: `This user does not have a ${label} profile` });
        }

        const profileId = profile.rows[0].ProfileId;
        const records = await client.query(
            `SELECT 1 FROM "MedicalRecords" WHERE ${recordColumn} = $1 LIMIT 1`,
            [profileId]
        );
        if (records.rowCount) {
            await client.query('ROLLBACK');
            return res.status(409).json({
                success: false,
                message: `Cannot remove this ${label} profile because medical records depend on it.`
            });
        }

        if (isPatient) {
            await client.query('DELETE FROM "Permissions" WHERE "PatientId" = $1', [profileId]);
        } else {
            await client.query('DELETE FROM "Permissions" WHERE "DoctorId" = $1', [profileId]);
        }

        await client.query(`DELETE FROM ${profileTable} WHERE "UserId" = $1`, [userId]);
        await client.query('COMMIT');
        return res.json({ success: true, message: `${label} profile removed successfully` });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error(`Remove ${label} profile error:`, error);
        return res.status(500).json({ success: false, message: `Failed to remove ${label} profile` });
    } finally {
        client.release();
    }
}

async function removePatientProfile(req, res) {
    return removeProfile(req, res, 'patient');
}

async function removeDoctorProfile(req, res) {
    return removeProfile(req, res, 'doctor');
}

// Destructive endpoint: calling it permanently deletes the selected user's related records.
async function deleteUserAccount(req, res) {
    const userId = Number(req.params.userId);
    const currentUserId = req.user.userId;

    if (!Number.isSafeInteger(userId) || userId <= 0) {
        return res.status(400).json({ success: false, message: 'Invalid user ID' });
    }
    if (userId === currentUserId) {
        return res.status(403).json({ success: false, message: 'You cannot delete your own account from the admin dashboard' });
    }

    const pool = getPool();
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        const user = await client.query(
            'SELECT "UserId" FROM "Users" WHERE "UserId" = $1 FOR UPDATE',
            [userId]
        );
        if (!user.rowCount) {
            await client.query('ROLLBACK');
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        const targetAdmin = await client.query(
            `SELECT 1 FROM "UserRoles" WHERE "UserId" = $1 AND "Role" = 'admin'`,
            [userId]
        );
        if (targetAdmin.rowCount) {
            const count = await client.query(
                `SELECT COUNT(DISTINCT "UserId")::int AS "AdminCount"
                 FROM "UserRoles" WHERE "Role" = 'admin'`
            );
            if (count.rows[0].AdminCount <= 1) {
                await client.query('ROLLBACK');
                return res.status(409).json({ success: false, message: 'Cannot delete the last administrator' });
            }
        }

        await client.query(
            `DELETE FROM "Permissions"
             WHERE "PatientId" IN (SELECT "PatientId" FROM "PatientProfiles" WHERE "UserId" = $1)
                OR "DoctorId" IN (SELECT "DoctorId" FROM "DoctorProfiles" WHERE "UserId" = $1)`,
            [userId]
        );

        await client.query(
            `DELETE FROM "MedicalRecords"
             WHERE "PatientId" IN (SELECT "PatientId" FROM "PatientProfiles" WHERE "UserId" = $1)
                OR "DoctorId" IN (SELECT "DoctorId" FROM "DoctorProfiles" WHERE "UserId" = $1)`,
            [userId]
        );
        await client.query('DELETE FROM "PatientProfiles" WHERE "UserId" = $1', [userId]);
        await client.query('DELETE FROM "DoctorProfiles" WHERE "UserId" = $1', [userId]);
        await client.query('DELETE FROM "UserRoles" WHERE "UserId" = $1', [userId]);
        await client.query('DELETE FROM "Users" WHERE "UserId" = $1', [userId]);

        await client.query('COMMIT');
        return res.json({ success: true, message: 'User account and related records deleted successfully' });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Delete user account error:', error);
        return res.status(500).json({ success: false, message: 'Failed to delete user account' });
    } finally {
        client.release();
    }
}

module.exports = {
    getUsers,
    setAdminRole,
    removePatientProfile,
    removeDoctorProfile,
    deleteUserAccount
};
