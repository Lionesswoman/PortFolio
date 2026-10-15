const mysql = require('mysql2/promise');

const env = process.env;

// SSL : obligatoire pour les bases MySQL en ligne (Aiven, TiDB…), inutile en local
let ssl;
if (env.DB_SSL === 'true') {
  ssl = env.DB_SSL_CA
    ? { ca: env.DB_SSL_CA.replace(/\\n/g, '\n'), rejectUnauthorized: true }
    : { rejectUnauthorized: false };
}

module.exports = mysql.createPool({
  host: env.MYSQLHOST || env.DB_HOST || 'localhost',
  port: Number(env.MYSQLPORT || env.DB_PORT) || 3306,
  user: env.MYSQLUSER || env.DB_USER || 'root',
  password: env.MYSQLPASSWORD || env.DB_PASSWORD || '',
  database: env.MYSQLDATABASE || env.DB_NAME || 'portfolio',
  ssl,
  waitForConnections: true,
  connectionLimit: 5,
  charset: 'utf8mb4',
});