require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('../config/db');

(async () => {
  const [username, password] = process.argv.slice(2);
  if (!username || !password || password.length < 8) {
    console.log('Usage : npm run create-admin -- <identifiant> <mot_de_passe (8 caractères min.)>');
    process.exit(1);
  }
  const hash = await bcrypt.hash(password, 12);
  await pool.query(
    'INSERT INTO admins (username, password_hash) VALUES (?, ?) ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash)',
    [username, hash]
  );
  console.log(`✅ Administrateur "${username}" prêt.`);
  process.exit(0);
})().catch((e) => {
  console.error('❌', e.message);
  process.exit(1);
});
