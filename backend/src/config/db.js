const sql = require('mssql');

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,

    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

let pool;

async function connectDB() {
    try {
        pool = await sql.connect(config);

        console.log('SQL Server connected successfully');

        return pool;
    } catch (error) {
        console.error('SQL Server connection failed:', error);
        throw error;
    }
}

function getPool() {
    if (!pool) {
        throw new Error('Database is not connected');
    }

    return pool;
}

module.exports = {
    sql,
    connectDB,
    getPool
};