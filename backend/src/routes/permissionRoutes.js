const express = require('express');

const {
    request,
    getPatientRequests,
    updateStatus,
    getDoctorApprovedPatientsController
} = require('../controllers/permissionController');

const router = express.Router();


router.post('/request', request);

router.get(
    '/patient/:patientId',
    getPatientRequests
);

router.put(
    '/:permissionId/status',
    updateStatus
);

router.get(
    '/doctor/:doctorId/approved',
    getDoctorApprovedPatientsController
);

module.exports = router;