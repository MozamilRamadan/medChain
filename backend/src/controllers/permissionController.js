const {
    requestPermission,
    getPatientPermissions,
    updatePermissionStatus,
    getDoctorApprovedPatients
} = require('../services/permissionService');


async function request(req, res) {
    try {
        const {
            patientId,
            doctorId
        } = req.body;

        if (!patientId || !doctorId) {
            return res.status(400).json({
                success: false,
                message: 'patientId and doctorId are required'
            });
        }

        const permission = await requestPermission({
            patientId,
            doctorId
        });

        res.status(201).json({
            success: true,
            message: 'Permission request created',
            permission
        });

    } catch (error) {
        console.error('Permission request error:', error);

        res.status(400).json({
            success: false,
            message: error.message
        });
    }
}


async function getPatientRequests(req, res) {
    try {
        const patientId = parseInt(req.params.patientId);

        if (isNaN(patientId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid patientId'
            });
        }

        const permissions =
            await getPatientPermissions(patientId);

        res.json({
            success: true,
            permissions
        });

    } catch (error) {
        console.error(
            'Get patient permissions error:',
            error
        );

        res.status(400).json({
            success: false,
            message: error.message
        });
    }
}


async function updateStatus(req, res) {
    try {
        const permissionId =
            parseInt(req.params.permissionId);

        const { status } = req.body;

        if (isNaN(permissionId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid permissionId'
            });
        }

        if (!status) {
            return res.status(400).json({
                success: false,
                message: 'status is required'
            });
        }

        const permission =
            await updatePermissionStatus({
                permissionId,
                status
            });

        res.json({
            success: true,
            message: `Permission ${status}`,
            permission
        });

    } catch (error) {
        console.error(
            'Update permission error:',
            error
        );

        res.status(400).json({
            success: false,
            message: error.message
        });
    }
}

async function getDoctorApprovedPatientsController(req, res) {
    try {
        const doctorId = parseInt(req.params.doctorId);

        if (isNaN(doctorId)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid doctorId'
            });
        }

        const patients = await getDoctorApprovedPatients(
            doctorId
        );

        res.json({
            success: true,
            patients
        });

    } catch (error) {
        console.error(
            'Get doctor approved patients error:',
            error
        );

        res.status(400).json({
            success: false,
            message: error.message
        });
    }
}


module.exports = {
    request,
    getPatientRequests,
    updateStatus,
    getDoctorApprovedPatientsController
};