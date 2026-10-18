const { sql, getPool } = require("../config/db");

const {
    addRecord: addBlockchainRecord
} = require("../services/blockchainService");

const {
    uploadRecord
} = require("../services/ipfsService");

const {
    checkDoctorPermission,
    saveMedicalRecord,
    getPatientRecords,
    getDoctorRecords
} = require("../services/recordService");


// GET /api/records/:patientId
async function getRecords(req, res) {
    try {
        const patientId = parseInt(req.params.patientId);

        if (isNaN(patientId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid patientId"
            });
        }


        const pool = getPool(); 
            const ownership = await pool
                .request()
                .input("UserId", sql.Int, req.user.userId)
                .query(`
                    SELECT TOP (1) PatientId
                    FROM dbo.PatientProfiles
                    WHERE UserId = @UserId
                `);

            if (ownership.recordset.length === 0) {
                return res.status(403).json({
                    success: false,
                    message: "A patient account is required"
                });
            }

            const ownPatientId =
                ownership.recordset[0].PatientId;

            if (ownPatientId !== patientId) {
                return res.status(403).json({
                    success: false,
                    message: "You can only access your own medical records"
                });
            }

            
        const records = await getPatientRecords(
            patientId
        );

        res.status(200).json({
            success: true,
            records
        });

    } catch (error) {
        console.error(
            "Get records error:",
            error
        );

        res.status(500).json({
            success: false,
            message: "Failed to get medical records",
            error: error.message
        });
    }
}


// POST /api/records
async function addRecord(req, res) {
    try {
        const {
            patientId,
            doctorId,
            diagnosis,
            notes
        } = req.body;


        // Validate required fields
        if (
            !patientId ||
            !doctorId ||
            !diagnosis
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Patient ID, doctor ID and diagnosis are required"
            });
        }


        const parsedPatientId =
            parseInt(patientId);

        const parsedDoctorId =
            parseInt(doctorId);


        if (
            isNaN(parsedPatientId) ||
            isNaN(parsedDoctorId)
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Patient ID and doctor ID must be valid numbers"
            });
        }


        // 1. Check doctor permission
        const hasPermission =
            await checkDoctorPermission(
                parsedPatientId,
                parsedDoctorId
            );

        if (!hasPermission) {
            return res.status(403).json({
                success: false,
                message:
                    "Doctor does not have approved permission"
            });
        }


        // 2. Create medical record data
        const recordData = {
            patientId: parsedPatientId,
            doctorId: parsedDoctorId,
            diagnosis,
            notes: notes || "",
            createdAt: new Date().toISOString()
        };


        // 3. Upload record data to IPFS
        const cid =
            await uploadRecord(recordData);

        console.log(
            "IPFS CID:",
            cid
        );


        // 4. Save CID on Polygon Blockchain
        const txHash =
            await addBlockchainRecord(
                parsedPatientId.toString(),
                cid
            );

        console.log(
            "Blockchain Transaction:",
            txHash
        );


        // 5. Save record in SQL Server
        const sqlRecord =
            await saveMedicalRecord({
                patientId: parsedPatientId,
                doctorId: parsedDoctorId,
                diagnosis,
                notes,
                ipfsCID: cid,
                blockchainRecordId: txHash
            });


        // 6. Return result
        res.status(201).json({
            success: true,
            message:
                "Medical record added successfully",

            record: sqlRecord,

            cid,

            transactionHash: txHash
        });

    } catch (error) {
        console.error(
            "Add record error:",
            error
        );

        res.status(500).json({
            success: false,
            message:
                "Failed to add medical record",
            error: error.message
        });
    }
}


// GET /api/records/doctor/:doctorId/patient/:patientId
async function getDoctorPatientRecords(req, res) {
    try {
        const doctorId =
            parseInt(req.params.doctorId);

        const patientId =
            parseInt(req.params.patientId);


        if (
            isNaN(doctorId) ||
            isNaN(patientId)
        ) {
            return res.status(400).json({
                success: false,
                message:
                    "Invalid doctorId or patientId"
            });
        }


        // Permission is checked inside getDoctorRecords()
        const records =
            await getDoctorRecords({
                doctorId,
                patientId
            });


        res.status(200).json({
            success: true,
            records
        });

    } catch (error) {
        console.error(
            "Get doctor records error:",
            error
        );

        res.status(403).json({
            success: false,
            message: error.message
        });
    }
}


module.exports = {
    getRecords,
    addRecord,
    getDoctorPatientRecords
};