
const jwt = require('jsonwebtoken');
const { sql, getPool } = require('../config/db');

async function requireAuth(req, res, next) {
    try {
        const authorization = req.headers.authorization;

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Authentication token is required'
            });
        }

        const token = authorization.slice(7).trim();

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Authentication token is required'
            });
        }

        if (!process.env.JWT_SECRET) {
            console.error('JWT_SECRET is not configured');

            return res.status(500).json({
                success: false,
                message: 'Server authentication is not configured'
            });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        if (!Number.isInteger(decoded.userId)) {
            return res.status(401).json({
                success: false,
                message: 'Invalid authentication token'
            });
        }

        req.user = {
            userId: decoded.userId
        };

        next();
    } catch (error) {
        if (
            error.name === 'JsonWebTokenError' ||
            error.name === 'TokenExpiredError' ||
            error.name === 'NotBeforeError'
        ) {
            return res.status(401).json({
                success: false,
                message: 'Invalid or expired authentication token'
            });
        }

        console.error('Authentication error:', error);

        return res.status(500).json({
            success: false,
            message: 'Authentication failed'
        });
    }
}

async function requireAdmin(req, res, next) {
    try {
        const pool = getPool();

        const result = await pool
            .request()
            .input('UserId', sql.Int, req.user.userId)
            .query(`
                SELECT TOP (1) UserRoleId
                FROM dbo.UserRoles
                WHERE UserId = @UserId
                  AND Role = N'admin'
            `);

        if (result.recordset.length === 0) {
            return res.status(403).json({
                success: false,
                message: 'Administrator permission is required'
            });
        }

        next();
    } catch (error) {
        console.error('Admin authorization error:', error);

        return res.status(500).json({
            success: false,
            message: 'Could not verify administrator permission'
        });
    }
}

module.exports = {
    requireAuth,
    requireAdmin
};
