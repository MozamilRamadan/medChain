const { getPool } = require('../config/db');

async function checkDoctorPermission(patientId, doctorId) {
    const pool = getPool();
    const result = await pool.query(
        `SELECT 1 FROM "Permissions"
         WHERE "PatientId" = $1 AND "DoctorId" = $2 AND "Status" = 'approved'
         LIMIT 1`,
        [patientId, doctorId]
    );
    return result.rowCount > 0;
}

async function saveMedicalRecord({
    patientId, doctorId, diagnosis, notes, ipfsCID, blockchainRecordId
}) {
    const pool = getPool();
    const result = await pool.query(
        `INSERT INTO "MedicalRecords"
            ("PatientId", "DoctorId", "Diagnosis", "Notes", "IpfsCID", "BlockchainRecordId")
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING "RecordId", "PatientId", "DoctorId", "Diagnosis",
                   "Notes", "IpfsCID", "BlockchainRecordId", "CreatedAt"`,
        [patientId, doctorId, diagnosis, notes || null, ipfsCID || null, blockchainRecordId || null]
    );
    return result.rows[0];
}

async function getPatientRecords(patientId) {
    const pool = getPool();
    const result = await pool.query(
        `SELECT
            r."RecordId", r."PatientId", r."DoctorId", r."Diagnosis",
            r."Notes", r."IpfsCID", r."BlockchainRecordId", r."CreatedAt",
            u."FullName" AS "DoctorName",
            u."ProfileImagePath" AS "DoctorProfileImagePath",
            d."Specialization"
         FROM "MedicalRecords" r
         INNER JOIN "DoctorProfiles" d ON r."DoctorId" = d."DoctorId"
         INNER JOIN "Users" u ON d."UserId" = u."UserId"
         WHERE r."PatientId" = $1
         ORDER BY r."CreatedAt" DESC`,
        [patientId]
    );
    return result.rows;
}

async function getDoctorRecords({ doctorId, patientId }) {
    const allowed = await checkDoctorPermission(patientId, doctorId);
    if (!allowed) throw new Error('Doctor does not have approved permission');

    const pool = getPool();
    const result = await pool.query(
        `SELECT
            r."RecordId", r."PatientId", r."DoctorId", r."Diagnosis",
            r."Notes", r."IpfsCID", r."BlockchainRecordId", r."CreatedAt",
            pu."FullName" AS "PatientName",
            pu."ProfileImagePath" AS "PatientProfileImagePath"
         FROM "MedicalRecords" r
         INNER JOIN "PatientProfiles" pp ON r."PatientId" = pp."PatientId"
         INNER JOIN "Users" pu ON pp."UserId" = pu."UserId"
         WHERE r."PatientId" = $1 AND r."DoctorId" = $2
         ORDER BY r."CreatedAt" DESC`,
        [patientId, doctorId]
    );
    return result.rows;
}

module.exports = {
    checkDoctorPermission,
    saveMedicalRecord,
    getPatientRecords,
    getDoctorRecords
};
