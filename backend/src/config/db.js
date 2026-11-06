require('dotenv').config();

const { Pool } = require('pg');

if (!process.env.DATABASE_URL) {
    throw new Error('DATABASE_URL is missing from .env');
}

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    connectionTimeoutMillis: 10000,
    idleTimeoutMillis: 30000,
    query_timeout: 15000,
    max: 10
});

pool.on('error', (error) => {
    console.error('Unexpected PostgreSQL pool error:', error);
});

async function connectDB() {
    try {
        const client = await pool.connect();

        console.log('PostgreSQL connected successfully');

        client.release();

        return pool;
    } catch (error) {
        console.error('PostgreSQL connection failed:', error.message);
        throw error;
    }
}

console.log('DATABASE_URL exists:', !!process.env.DATABASE_URL);

if (process.env.DATABASE_URL) {
    console.log(
        'DATABASE HOST:',
        new URL(process.env.DATABASE_URL).hostname
    );
}

function getPool() {
    return pool;
}

module.exports = {
    pool,
    connectDB,
    getPool
};