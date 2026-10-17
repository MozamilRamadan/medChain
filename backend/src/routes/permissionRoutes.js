
const express = require('express');

const {
  request,
  getPatientRequests,
  updateStatus,
  getDoctorApprovedPatientsController,
  revokePermissionController
} = require('../controllers/permissionController');

const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/request', request);

router.get('/patient/:patientId', getPatientRequests);

router.put('/:permissionId/status', updateStatus);

router.put(
  '/:permissionId/revoke',
  requireAuth,
  revokePermissionController
);

router.get(
  '/doctor/:doctorId/approved',
  getDoctorApprovedPatientsController
);

module.exports = router;
