const {
    registerUser,
    loginUser
} = require('../services/authService');

async function register(req, res) {
    try {
        const {
            fullName,
            phone,
            nationalId,
            password,
            roles,
            licenseNumber,
            specialization
        } = req.body;

        if (
            !fullName ||
            !phone ||
            !nationalId ||
            !password ||
            !roles
        ) {
            return res.status(400).json({
                success: false,
                message: 'Missing required fields'
            });
        }

        const result = await registerUser({
            fullName,
            phone,
            nationalId,
            password,
            roles,
            licenseNumber,
            specialization
        });

        res.status(201).json({
            success: true,
            message: 'Account created successfully',
            ...result
        });

    } catch (error) {
        console.error('Register error:', error);

        res.status(400).json({
            success: false,
            message: error.message
        });
    }
}

async function login(req, res) {
    try {
        const {
            nationalId,
            password
        } = req.body;

        if (!nationalId || !password) {
            return res.status(400).json({
                success: false,
                message: 'National ID and password are required'
            });
        }

        const result = await loginUser({
            nationalId,
            password
        });

        res.json({
            success: true,
            ...result
        });

    } catch (error) {
        console.error('Login error:', error);

        res.status(401).json({
            success: false,
            message: error.message
        });
    }
}

module.exports = {
    register,
    login
};