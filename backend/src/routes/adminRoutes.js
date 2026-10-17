const express = require('express');

const {
    getUsers,
    setAdminRole,
    removePatientProfile,
    removeDoctorProfile,
    deleteUserAccount
} = require('../controllers/adminController');

const {
    requireAuth,
    requireAdmin
} = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/users', requireAuth, requireAdmin, getUsers);

router.put(
    '/users/:userId/admin-role',
    requireAuth,
    requireAdmin,
    setAdminRole
);

router.delete(
    '/users/:userId/patient-profile',
    requireAuth,
    requireAdmin,
    removePatientProfile
);

router.delete(
    '/users/:userId/doctor-profile',
    requireAuth,
    requireAdmin,
    removeDoctorProfile
);

router.delete(
    '/users/:userId',
    requireAuth,
    requireAdmin,
    deleteUserAccount
);

module.exports = router;