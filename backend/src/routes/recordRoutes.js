const express = require("express");

const {
    getRecords,
    addRecord,
    getDoctorPatientRecords
} = require("../controllers/recordController");

const router = express.Router();

const { requireAuth } =
    require("../middleware/authMiddleware");

// Patient records
router.get("/:patientId", requireAuth, getRecords);


// Add record
router.post("/", addRecord);


// Doctor → Patient records
router.get(
    "/doctor/:doctorId/patient/:patientId",
    getDoctorPatientRecords
);


module.exports = router;