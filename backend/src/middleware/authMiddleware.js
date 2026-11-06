const jwt = require('jsonwebtoken');
const { getPool } = require('../config/db');

async function requireAuth(req, res, next) {
    try {
        const authorization = req.headers.authorization;
        if (!authorization?.startsWith('Bearer ')) {
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

        req.user = { userId: decoded.userId };
        return next();
    } catch (error) {
        if (['JsonWebTokenError', 'TokenExpiredError', 'NotBeforeError'].includes(error.name)) {
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
        const result = await pool.query(
            `SELECT 1 FROM "UserRoles"
             WHERE "UserId" = $1 AND "Role" = 'admin'
             LIMIT 1`,
            [req.user.userId]
        );

        if (!result.rowCount) {
            return res.status(403).json({
                success: false,
                message: 'Administrator permission is required'
            });
        }

        return next();
    } catch (error) {
        console.error('Admin authorization error:', error);
        return res.status(500).json({
            success: false,
            message: 'Could not verify administrator permission'
        });
    }
}

module.exports = { requireAuth, requireAdmin };
