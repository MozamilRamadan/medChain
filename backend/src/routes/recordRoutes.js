const express = require("express");

const {
    getRecords,
    addRecord,
    getDoctorPatientRecords
} = require("../controllers/recordController");

const router = express.Router();


// Patient records
router.get("/:patientId", getRecords);


// Add record
router.post("/", addRecord);


// Doctor → Patient records
router.get(
    "/doctor/:doctorId/patient/:patientId",
    getDoctorPatientRecords
);


module.exports = router;