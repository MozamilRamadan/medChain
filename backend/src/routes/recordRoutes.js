
const express = require("express");

const {
    getRecords,
    addRecord,
    getDoctorPatientRecords,
    deleteRecord
} = require("../controllers/recordController");

const { requireAuth } = require("../middleware/authMiddleware");

const router = express.Router();

// Patient records
router.get("/:patientId", getRecords);

// Add record
router.post("/", addRecord);

// Delete record: authentication is mandatory.
router.delete("/:recordId", requireAuth, deleteRecord);

// Doctor → Patient records
router.get(
    "/doctor/:doctorId/patient/:patientId",
    getDoctorPatientRecords
);

module.exports = router;
