
const { getPool } = require('../config/db');

// Check whether a doctor has approved permission to access a patient's records.
async function checkDoctorPermission(patientId, doctorId) {
    const pool = getPool();

    const result = await pool.query(
        `SELECT 1
         FROM "Permissions"
         WHERE "PatientId" = $1
           AND "DoctorId" = $2
           AND "Status" = 'approved'
         LIMIT 1`,
        [patientId, doctorId]
    );

    return result.rowCount > 0;
}

// Save a medical record in PostgreSQL.
// BlockchainRecordId is optional and can be NULL.
async function saveMedicalRecord({
    patientId,
    doctorId,
    diagnosis,
    notes,
    ipfsCID,
    blockchainRecordId = null
}) {
    const pool = getPool();

    const result = await pool.query(
        `INSERT INTO "MedicalRecords"
            (
                "PatientId",
                "DoctorId",
                "Diagnosis",
                "Notes",
                "IpfsCID",
                "BlockchainRecordId"
            )
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING
            "RecordId",
            "PatientId",
            "DoctorId",
            "Diagnosis",
            "Notes",
            "IpfsCID",
            "BlockchainRecordId",
            "CreatedAt"`,
        [
            patientId,
            doctorId,
            diagnosis,
            notes || null,
            ipfsCID || null,
            blockchainRecordId
        ]
    );

    return result.rows[0];
}

// Get all records belonging to a patient.
async function getPatientRecords(patientId) {
    const pool = getPool();

    const result = await pool.query(
        `SELECT
            r."RecordId",
            r."PatientId",
            r."DoctorId",
            r."Diagnosis",
            r."Notes",
            r."IpfsCID",
            r."BlockchainRecordId",
            r."CreatedAt",
            u."FullName" AS "DoctorName",
            u."ProfileImagePath" AS "DoctorProfileImagePath",
            d."Specialization"
         FROM "MedicalRecords" r
         INNER JOIN "DoctorProfiles" d
            ON r."DoctorId" = d."DoctorId"
         INNER JOIN "Users" u
            ON d."UserId" = u."UserId"
         WHERE r."PatientId" = $1
         ORDER BY r."CreatedAt" DESC`,
        [patientId]
    );

    return result.rows;
}

// Get records created by a doctor for a specific patient.
async function getDoctorRecords({ doctorId, patientId }) {
    const allowed = await checkDoctorPermission(patientId, doctorId);

    if (!allowed) {
        throw new Error('Doctor does not have approved permission');
    }

    const pool = getPool();

    const result = await pool.query(
        `SELECT
            r."RecordId",
            r."PatientId",
            r."DoctorId",
            r."Diagnosis",
            r."Notes",
            r."IpfsCID",
            r."BlockchainRecordId",
            r."CreatedAt",
            pu."FullName" AS "PatientName",
            pu."ProfileImagePath" AS "PatientProfileImagePath"
         FROM "MedicalRecords" r
         INNER JOIN "PatientProfiles" pp
            ON r."PatientId" = pp."PatientId"
         INNER JOIN "Users" pu
            ON pp."UserId" = pu."UserId"
         WHERE r."PatientId" = $1
           AND r."DoctorId" = $2
         ORDER BY r."CreatedAt" DESC`,
        [patientId, doctorId]
    );

    return result.rows;
}

// Delete a record only if the authenticated user is either:
// 1. The patient who owns the record.
// 2. The doctor who created the record.
async function deleteMedicalRecord({ recordId, userId }) {
    const pool = getPool();

    const result = await pool.query(
        `DELETE FROM "MedicalRecords" AS r
         WHERE r."RecordId" = $1
           AND (
               EXISTS (
                   SELECT 1
                   FROM "PatientProfiles" pp
                   WHERE pp."PatientId" = r."PatientId"
                     AND pp."UserId" = $2
               )
               OR
               EXISTS (
                   SELECT 1
                   FROM "DoctorProfiles" dp
                   WHERE dp."DoctorId" = r."DoctorId"
                     AND dp."UserId" = $2
               )
           )
         RETURNING r."RecordId"`,
        [recordId, userId]
    );

    if (result.rowCount === 0) {
        const error = new Error(
            'Record not found or you are not authorized to delete it'
        );
        error.code = 'RECORD_NOT_FOUND_OR_FORBIDDEN';
        throw error;
    }

    return result.rows[0];
}

module.exports = {
    checkDoctorPermission,
    saveMedicalRecord,
    getPatientRecords,
    getDoctorRecords,
    deleteMedicalRecord
};
