const mysql = require('mysql2/promise');

const env = process.env;

module.exports = mysql.createPool({
  host: env.MYSQLHOST || env.DB_HOST || 'localhost',
  port: Number(env.MYSQLPORT || env.DB_PORT) || 3306,
  user: env.MYSQLUSER || env.DB_USER || 'root',
  password: env.MYSQLPASSWORD || env.DB_PASSWORD || '',
  database: env.MYSQLDATABASE || env.DB_NAME || 'portfolio',
  waitForConnections: true,
  connectionLimit: 10,
  charset: 'utf8mb4',
});