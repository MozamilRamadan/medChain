
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
    getDoctorRecords,
    deleteMedicalRecord
} = require("../services/recordService");


// GET /api/records/:patientId
async function getRecords(req, res) {
    try {
        const patientId = Number(req.params.patientId);

        if (!Number.isInteger(patientId) || patientId <= 0) {
            return res.status(400).json({
                success: false,
                message: "Invalid patientId"
            });
        }

        const records = await getPatientRecords(patientId);

        return res.status(200).json({
            success: true,
            records
        });
    } catch (error) {
        console.error("Get records error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to get medical records"
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

        if (!patientId || !doctorId || !diagnosis) {
            return res.status(400).json({
                success: false,
                message: "Patient ID, doctor ID and diagnosis are required"
            });
        }

        const parsedPatientId = Number(patientId);
        const parsedDoctorId = Number(doctorId);

        if (
            !Number.isInteger(parsedPatientId) ||
            parsedPatientId <= 0 ||
            !Number.isInteger(parsedDoctorId) ||
            parsedDoctorId <= 0
        ) {
            return res.status(400).json({
                success: false,
                message: "Patient ID and doctor ID must be valid numbers"
            });
        }

        const hasPermission = await checkDoctorPermission(
            parsedPatientId,
            parsedDoctorId
        );

        if (!hasPermission) {
            return res.status(403).json({
                success: false,
                message: "Doctor does not have approved permission"
            });
        }

        const recordData = {
            patientId: parsedPatientId,
            doctorId: parsedDoctorId,
            diagnosis,
            notes: notes || "",
            createdAt: new Date().toISOString()
        };

        const cid = await uploadRecord(recordData);

        console.log("IPFS CID:", cid);

        const txHash = await addBlockchainRecord(
            parsedPatientId.toString(),
            cid
        );

        console.log("Blockchain Transaction:", txHash);

        const sqlRecord = await saveMedicalRecord({
            patientId: parsedPatientId,
            doctorId: parsedDoctorId,
            diagnosis,
            notes,
            ipfsCID: cid,
            blockchainRecordId: txHash
        });

        return res.status(201).json({
            success: true,
            message: "Medical record added successfully",
            record: sqlRecord,
            cid,
            transactionHash: txHash
        });
    } catch (error) {
        console.error("Add record error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to add medical record",
            error: error.message
        });
    }
}


// GET /api/records/doctor/:doctorId/patient/:patientId
async function getDoctorPatientRecords(req, res) {
    try {
        const doctorId = Number(req.params.doctorId);
        const patientId = Number(req.params.patientId);

        if (
            !Number.isInteger(doctorId) || doctorId <= 0 ||
            !Number.isInteger(patientId) || patientId <= 0
        ) {
            return res.status(400).json({
                success: false,
                message: "Invalid doctorId or patientId"
            });
        }

        const records = await getDoctorRecords({
            doctorId,
            patientId
        });

        return res.status(200).json({
            success: true,
            records
        });
    } catch (error) {
        console.error("Get doctor records error:", error);

        return res.status(403).json({
            success: false,
            message: error.message
        });
    }
}


// DELETE /api/records/:recordId
async function deleteRecord(req, res) {
    try {
        const recordId = Number(req.params.recordId);

        if (!Number.isInteger(recordId) || recordId <= 0) {
            return res.status(400).json({
                success: false,
                message: "Invalid record ID"
            });
        }

        // req.user.userId is set by requireAuth middleware.
        const deletedRecord = await deleteMedicalRecord({
            recordId,
            userId: req.user.userId
        });

        return res.status(200).json({
            success: true,
            message: "Medical record deleted from SQL Server",
            recordId: deletedRecord.RecordId
        });
    } catch (error) {
        if (error.code === "RECORD_NOT_FOUND_OR_FORBIDDEN") {
            return res.status(404).json({
                success: false,
                message: error.message
            });
        }

        console.error("Delete record error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to delete medical record"
        });
    }
}


module.exports = {
    getRecords,
    addRecord,
    getDoctorPatientRecords,
    deleteRecord
};
