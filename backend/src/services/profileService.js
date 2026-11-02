
const { sql, getPool } = require('../config/db');

async function getMyProfile(userId) {
  const pool = await getPool();

  const result = await pool.request()
    .input('userId', sql.Int, userId)
    .query(`
      SELECT
        U.UserId AS userId,
        U.FullName AS fullName,
        U.Phone AS phone,
        U.NationalId AS nationalId,
        U.ProfileImagePath AS profileImagePath,
        P.PatientId AS patientId,
        D.DoctorId AS doctorId,
        D.LicenseNumber AS licenseNumber,
        D.Specialization AS specialization
      FROM dbo.Users U
      LEFT JOIN dbo.PatientProfiles P ON P.UserId = U.UserId
      LEFT JOIN dbo.DoctorProfiles D ON D.UserId = U.UserId
      WHERE U.UserId = @userId;
    `);

  if (result.recordset.length === 0) {
    throw new Error('User not found');
  }

  const roleResult = await pool.request()
    .input('userId', sql.Int, userId)
    .query(`
      SELECT Role
      FROM dbo.UserRoles
      WHERE UserId = @userId;
    `);

  const profile = result.recordset[0];

  return {
    ...profile,
    roles: roleResult.recordset.map(row => row.Role),
  };
}

async function updateMyProfile(userId, { fullName, phone }) {
  if (!fullName || !fullName.trim()) {
    throw new Error('Full name is required');
  }

  if (!phone || !phone.trim()) {
    throw new Error('Phone is required');
  }

  const pool = await getPool();

  const result = await pool.request()
    .input('userId', sql.Int, userId)
    .input('fullName', sql.NVarChar(255), fullName.trim())
    .input('phone', sql.NVarChar(50), phone.trim())
    .query(`
      UPDATE dbo.Users
      SET FullName = @fullName,
          Phone = @phone
      WHERE UserId = @userId;

      SELECT @@ROWCOUNT AS affectedRows;
    `);

  if (result.recordset[0].affectedRows === 0) {
    throw new Error('User not found');
  }

  return getMyProfile(userId);
}

async function updateProfileImage(userId, imagePath) {
  const pool = await getPool();

  const result = await pool.request()
    .input('userId', sql.Int, userId)
    .input('imagePath', sql.NVarChar(500), imagePath)
    .query(`
      UPDATE dbo.Users
      SET ProfileImagePath = @imagePath
      WHERE UserId = @userId;

      SELECT @@ROWCOUNT AS affectedRows;
    `);

  if (result.recordset[0].affectedRows === 0) {
    throw new Error('User not found');
  }

  return getMyProfile(userId);
}

module.exports = {
  getMyProfile,
  updateMyProfile,
  updateProfileImage,
};
