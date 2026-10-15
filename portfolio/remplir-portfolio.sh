#!/usr/bin/env bash
# Remplit tous les fichiers du portfolio, importe la base et crée le compte admin.
# Utilisation : placer ce fichier dans le dossier portfolio puis :  bash remplir-portfolio.sh
set -e
cd "$(dirname "$0")"

mkdir -p config middleware routes scripts database uploads public/css public/js admin-ui/assets

echo "📝 Écriture des fichiers..."

cat > .env.example <<'__FIN__'
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=3306
DB_USER=portfolio_user
DB_PASSWORD=
DB_NAME=portfolio
JWT_SECRET=remplace-moi-par-une-longue-chaine-aleatoire-de-64-caracteres
ADMIN_PATH=admin
__FIN__

cat > .gitignore <<'__FIN__'
node_modules/
.env
uploads/*
__FIN__

cat > package.json <<'__FIN__'
{
  "name": "portfolio",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node --watch server.js",
    "create-admin": "node scripts/create-admin.js"
  },
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "cookie-parser": "^1.4.6",
    "dotenv": "^16.4.5",
    "express": "^4.21.0",
    "express-rate-limit": "^7.4.0",
    "helmet": "^8.0.0",
    "jsonwebtoken": "^9.0.2",
    "multer": "^1.4.5-lts.1",
    "mysql2": "^3.11.0"
  }
}
__FIN__

# ---------------------------------------------------------------- database
cat > database/schema.sql <<'__FIN__'
CREATE DATABASE IF NOT EXISTS portfolio CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE portfolio;

CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS profile (
  id TINYINT PRIMARY KEY,
  full_name VARCHAR(120),
  title VARCHAR(160),
  bio TEXT,
  email VARCHAR(150),
  phone VARCHAR(40),
  location VARCHAR(120),
  github VARCHAR(255),
  linkedin VARCHAR(255),
  photo VARCHAR(255),
  cv VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS skills (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  category VARCHAR(80),
  level TINYINT UNSIGNED NOT NULL DEFAULT 80,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS projects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(160) NOT NULL,
  context VARCHAR(160),
  summary VARCHAR(500),
  description TEXT,
  tech VARCHAR(500),
  image VARCHAR(255),
  demo_url VARCHAR(255),
  repo_url VARCHAR(255),
  featured TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS experiences (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type ENUM('formation','stage','experience','projet') NOT NULL DEFAULT 'formation',
  title VARCHAR(160) NOT NULL,
  organization VARCHAR(160),
  period VARCHAR(80),
  description TEXT,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL,
  subject VARCHAR(200),
  message TEXT NOT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT IGNORE INTO profile (id, full_name, title, bio, location) VALUES
(1, 'Ton Nom', 'Développement Full-Stack • Web & Mobile',
 'En formation en Génie Logiciel (2ᵉ année) à l’Institut Africain d’Informatique – Cameroun, je conçois et développe des applications web et mobiles complètes : de l’analyse et la modélisation UML jusqu’au déploiement.\n\nJ’aime construire des plateformes utiles qui résolvent des problèmes concrets : réservation de transport, digitalisation de la presse, gestion d’accueil, sites d’actualités sportives…',
 'Yaoundé, Cameroun');

INSERT INTO skills (name, category, level, sort_order) VALUES
('Java / Spring Boot', 'Backend', 80, 1),
('Node.js / Express', 'Backend', 80, 2),
('Python / FastAPI', 'Backend', 70, 3),
('React', 'Frontend', 75, 4),
('HTML / CSS / JavaScript', 'Frontend', 85, 5),
('Flutter / Dart', 'Mobile', 75, 6),
('Machine Learning (prédiction)', 'IA & Data', 60, 7),
('PostgreSQL', 'Bases de données', 80, 8),
('MySQL', 'Bases de données', 80, 9),
('Redis', 'Bases de données', 60, 10),
('Docker', 'DevOps & outils', 65, 11),
('Git / GitHub', 'DevOps & outils', 80, 12),
('UML / Merise / GanttProject', 'Analyse & conception', 80, 13);

INSERT INTO projects (title, context, summary, description, tech, featured, sort_order) VALUES
('VIPGo', 'Stage académique — Albatres Ingénierie',
 'Plateforme intelligente de gestion de disponibilité, tarification et réservation en ligne de voyages interurbains en véhicules VIP.',
 'Application mobile Flutter connectée à un backend Spring Boot, avec un module d’intelligence artificielle en Python (FastAPI) entraîné sur l’historique des réservations pour la tarification et la disponibilité.\n\nIntégration du paiement réel CAMPOST (webhook), cache Redis, base PostgreSQL, conteneurisation Docker et déploiement sur Railway.\n\nModèle économique : commission par billet, abonnements des compagnies et contrats négociés.',
 'Spring Boot, Java, Flutter, Dart, Python, FastAPI, PostgreSQL, Redis, Docker, Railway', 1, 1),
('JEAF Sports Management', 'Projet client — Albatres Engineering',
 'Plateforme web de JEAF SPORTS MANAGEMENT Ltd (Malabo) : site d’actualités et médias sportifs + espace d’administration complet.',
 'Analyse, conception et réalisation en équipe de la plateforme : site public centré sur l’actualité, rubriques médias (catégories de sports, chaînes TV/Radio, direct) et back-office complet.\n\nAPI sécurisée par JWT, migrations Flyway, documentation Swagger, envoi d’e-mails via Brevo.',
 'Spring Boot, Java, React, PostgreSQL, JWT, Flyway, Swagger, Brevo', 1, 2),
('Plateforme SOPECAM', 'Projet académique',
 'Plateforme intelligente de gestion des abonnements, des ventes et de la distribution des journaux de la SOPECAM.',
 'Digitalisation des services de presse : gestion des abonnés, ventes, distribution et suivi.\n\nConception complète de la base de données, backend Node.js développé étape par étape, frontend en HTML/CSS/JavaScript natif et déverrouillage de la plateforme par reconnaissance faciale.',
 'Node.js, Express, MySQL, HTML, CSS, JavaScript', 1, 3),
('GEPT — CNPS', 'Stage — CNPS',
 'Informatisation de la gestion des enquêtes et du précontentieux technique.',
 'Application de gestion des enquêtes et du précontentieux technique réalisée dans le cadre de mon stage à la CNPS.',
 NULL, 0, 4),
('Système d’accueil des visiteurs', 'Projet en cours',
 'Les visiteurs scannent leurs documents officiels, le service concerné est notifié et un ticket numérique est délivré.',
 'Scan des pièces officielles via des dispositifs intelligents, transmission automatique au service concerné et ticket numérique (numéro de passage + service).\n\nGestion des rendez-vous, guichets, notifications et procédures d’évacuation. Comptes pour les employés et l’administrateur, aucun compte requis pour le visiteur.',
 NULL, 0, 5),
('Générateur de cartes scolaires', 'Groupe Scolaire Bilingue Saint Dominique',
 'Génération automatique des cartes d’identité scolaires à partir d’un modèle et d’un fichier d’élèves.',
 'Production en série des cartes d’identité des élèves (nom, prénom, matricule, classe, photo…) pour plusieurs classes à partir d’un modèle graphique et d’un fichier de données.',
 NULL, 0, 6);

INSERT INTO experiences (type, title, organization, period, description, sort_order) VALUES
('formation', 'Technicien Supérieur — Génie Logiciel', 'IAI-Cameroun (Institut Africain d’Informatique)', 'En cours — 2ᵉ année', 'Analyse, conception et développement d’applications.', 1),
('stage', 'Stage académique — Projet VIPGo', 'Albatres Ingénierie, Yaoundé', '2026', 'Conception et développement d’une plateforme de réservation de voyages VIP : Spring Boot, Flutter, IA FastAPI, paiement CAMPOST, déploiement Docker/Railway.', 2),
('stage', 'Stage — Application GEPT', 'CNPS', 'À préciser', 'Informatisation de la gestion des enquêtes et du précontentieux technique.', 3),
('projet', 'Plateforme web JEAF Sports Management', 'Albatres Engineering — client JEAF (Malabo)', '2026', 'Analyse, conception et réalisation en équipe du site public et de l’espace d’administration.', 4);
__FIN__

cat > database/github-projects.sql <<'__FIN__'
USE portfolio;

UPDATE profile SET github = 'https://github.com/Lionesswoman' WHERE id = 1;

UPDATE projects SET repo_url = 'https://github.com/Lionesswoman/VIPGo' WHERE title = 'VIPGo';
UPDATE projects SET repo_url = 'https://github.com/Lionesswoman/JEAF_MANAGEMENT_LTD' WHERE title = 'JEAF Sports Management';

INSERT INTO projects (title, context, summary, description, tech, repo_url, featured, sort_order) VALUES
('Mini Scanner App', 'Projet GitHub', 'Application de numérisation de documents.', 'Application de scan de documents. Description à compléter.', NULL, 'https://github.com/Lionesswoman/mini_scanner_app', 0, 7),
('AutomateIt — Site web', 'Projet GitHub', 'Site web vitrine AutomateIt.', 'Site web réalisé pour AutomateIt. Description à compléter.', NULL, 'https://github.com/Lionesswoman/automateit-website', 0, 8),
('YouCanSpeak', 'Projet GitHub', 'Application YouCanSpeak.', 'Description à compléter.', NULL, 'https://github.com/Lionesswoman/YouCanSpeak', 0, 9),
('Boutique en ligne', 'Projet GitHub', 'Application de boutique : catalogue de produits et gestion des achats.', 'Description à compléter.', NULL, 'https://github.com/Lionesswoman/Boutique', 0, 10),
('Convertisseur', 'Projet GitHub', 'Application de conversion.', 'Description à compléter.', NULL, 'https://github.com/Lionesswoman/Convertisseur', 0, 11),
('Projet Commun', 'Projet d’équipe', 'Projet réalisé en équipe.', 'Description à compléter.', NULL, 'https://github.com/Lionesswoman/projetCommun', 0, 12),
('Todo List', 'Projet GitHub', 'Application de gestion de tâches : ajout, modification, suppression et suivi.', 'Description à compléter.', NULL, 'https://github.com/Lionesswoman/todolist', 0, 13);
__FIN__

# ---------------------------------------------------------------- backend
cat > config/db.js <<'__FIN__'
const mysql = require('mysql2/promise');

module.exports = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'portfolio',
  waitForConnections: true,
  connectionLimit: 10,
  charset: 'utf8mb4',
});
__FIN__

cat > middleware/auth.js <<'__FIN__'
const jwt = require('jsonwebtoken');

const COOKIE_NAME = 'admin_token';

function isAuthenticated(req) {
  const token = req.cookies?.[COOKIE_NAME];
  if (!token) return null;
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch {
    return null;
  }
}

function requireAuthApi(req, res, next) {
  const admin = isAuthenticated(req);
  if (!admin) return res.status(401).json({ error: 'Non autorisé' });
  req.admin = admin;
  next();
}

const requireAuthPage = (adminPath) => (req, res, next) =>
  isAuthenticated(req) ? next() : res.redirect(`${adminPath}/login`);

module.exports = { COOKIE_NAME, isAuthenticated, requireAuthApi, requireAuthPage };
__FIN__

cat > routes/public.js <<'__FIN__'
const express = require('express');
const rateLimit = require('express-rate-limit');
const pool = require('../config/db');

const router = express.Router();
const wrap = (fn) => (req, res, next) => fn(req, res, next).catch(next);

router.get('/portfolio', wrap(async (req, res) => {
  const [[profile]] = await pool.query(
    'SELECT full_name, title, bio, email, phone, location, github, linkedin, photo, cv FROM profile WHERE id = 1'
  );
  const [skills] = await pool.query('SELECT name, category, level FROM skills ORDER BY sort_order, id');
  const [projects] = await pool.query(
    'SELECT id, title, context, summary, description, tech, image, demo_url, repo_url, featured FROM projects ORDER BY featured DESC, sort_order, id'
  );
  const [experiences] = await pool.query(
    'SELECT type, title, organization, period, description FROM experiences ORDER BY sort_order, id'
  );
  res.json({ profile: profile || {}, skills, projects, experiences });
}));

const contactLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Trop de messages envoyés, réessayez plus tard.' },
});

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

router.post('/contact', contactLimiter, wrap(async (req, res) => {
  const { name, email, subject, message, website } = req.body || {};
  if (website) return res.json({ ok: true });

  const n = String(name || '').trim();
  const e = String(email || '').trim();
  const s = String(subject || '').trim();
  const m = String(message || '').trim();

  if (n.length < 2 || !EMAIL_RE.test(e) || m.length < 10) {
    return res.status(400).json({ error: 'Merci de remplir correctement le nom, l’e-mail et le message (10 caractères min.).' });
  }
  if (n.length > 120 || e.length > 150 || s.length > 200 || m.length > 5000) {
    return res.status(400).json({ error: 'Un des champs est trop long.' });
  }

  await pool.query('INSERT INTO messages (name, email, subject, message) VALUES (?, ?, ?, ?)', [n, e, s || null, m]);
  res.json({ ok: true });
}));

module.exports = router;
__FIN__

cat > routes/admin.js <<'__FIN__'
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const pool = require('../config/db');
const { COOKIE_NAME, requireAuthApi } = require('../middleware/auth');

const router = express.Router();
const wrap = (fn) => (req, res, next) => fn(req, res, next).catch(next);

router.use((req, res, next) => {
  res.set('X-Robots-Tag', 'noindex, nofollow');
  res.set('Cache-Control', 'no-store');
  next();
});

const cookieOpts = {
  httpOnly: true,
  sameSite: 'strict',
  secure: process.env.NODE_ENV === 'production',
  path: '/',
};

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Trop de tentatives, réessaie dans 15 minutes.' },
});

router.post('/login', loginLimiter, wrap(async (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) return res.status(400).json({ error: 'Identifiant et mot de passe requis' });

  const [[admin]] = await pool.query('SELECT id, username, password_hash FROM admins WHERE username = ?', [username]);
  const ok = admin && (await bcrypt.compare(password, admin.password_hash));
  if (!ok) return res.status(401).json({ error: 'Identifiants incorrects' });

  const token = jwt.sign({ id: admin.id, username: admin.username }, process.env.JWT_SECRET, { expiresIn: '8h' });
  res.cookie(COOKIE_NAME, token, { ...cookieOpts, maxAge: 8 * 60 * 60 * 1000 });
  res.json({ ok: true });
}));

router.post('/logout', (req, res) => {
  res.clearCookie(COOKIE_NAME, cookieOpts);
  res.json({ ok: true });
});

router.use(requireAuthApi);

router.get('/me', (req, res) => res.json({ username: req.admin.username }));

router.put('/password', wrap(async (req, res) => {
  const { current, next: newPassword } = req.body || {};
  if (!newPassword || String(newPassword).length < 8) {
    return res.status(400).json({ error: 'Le nouveau mot de passe doit contenir au moins 8 caractères' });
  }
  const [[admin]] = await pool.query('SELECT password_hash FROM admins WHERE id = ?', [req.admin.id]);
  if (!admin || !(await bcrypt.compare(String(current || ''), admin.password_hash))) {
    return res.status(400).json({ error: 'Mot de passe actuel incorrect' });
  }
  const hash = await bcrypt.hash(String(newPassword), 12);
  await pool.query('UPDATE admins SET password_hash = ? WHERE id = ?', [hash, req.admin.id]);
  res.json({ ok: true });
}));

const pick = (body, fields) => {
  const out = {};
  for (const f of fields) {
    if (body && body[f] !== undefined) out[f] = body[f] === '' ? null : body[f];
  }
  return out;
};

const PROFILE_FIELDS = ['full_name', 'title', 'bio', 'email', 'phone', 'location', 'github', 'linkedin', 'photo', 'cv'];

router.get('/profile', wrap(async (req, res) => {
  const [[p]] = await pool.query('SELECT * FROM profile WHERE id = 1');
  res.json(p || {});
}));

router.put('/profile', wrap(async (req, res) => {
  const data = pick(req.body, PROFILE_FIELDS);
  if (!Object.keys(data).length) return res.status(400).json({ error: 'Aucune donnée' });
  await pool.query('INSERT INTO profile SET id = 1, ? ON DUPLICATE KEY UPDATE ?', [data, data]);
  res.json({ ok: true });
}));

const ALLOWED_EXT = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.pdf'];

const upload = multer({
  storage: multer.diskStorage({
    destination: path.join(__dirname, '..', 'uploads'),
    filename: (req, file, cb) =>
      cb(null, `${Date.now()}-${crypto.randomBytes(6).toString('hex')}${path.extname(file.originalname).toLowerCase()}`),
  }),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (ALLOWED_EXT.includes(path.extname(file.originalname).toLowerCase())) return cb(null, true);
    const err = new Error('Format non autorisé (jpg, png, webp, gif ou pdf)');
    err.status = 400;
    cb(err);
  },
});

router.post('/upload', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Aucun fichier reçu' });
  res.json({ url: `/uploads/${req.file.filename}` });
});

router.get('/messages', wrap(async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM messages ORDER BY created_at DESC');
  res.json(rows);
}));

router.patch('/messages/:id/read', wrap(async (req, res) => {
  await pool.query('UPDATE messages SET is_read = 1 WHERE id = ?', [Number(req.params.id)]);
  res.json({ ok: true });
}));

router.delete('/messages/:id', wrap(async (req, res) => {
  await pool.query('DELETE FROM messages WHERE id = ?', [Number(req.params.id)]);
  res.json({ ok: true });
}));

const ENTITIES = {
  projects: ['title', 'context', 'summary', 'description', 'tech', 'image', 'demo_url', 'repo_url', 'featured', 'sort_order'],
  skills: ['name', 'category', 'level', 'sort_order'],
  experiences: ['type', 'title', 'organization', 'period', 'description', 'sort_order'],
};

function getFields(req, res) {
  const fields = ENTITIES[req.params.entity];
  if (!fields) res.status(404).json({ error: 'Ressource inconnue' });
  return fields;
}

function getId(req, res) {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id < 1) {
    res.status(400).json({ error: 'Identifiant invalide' });
    return null;
  }
  return id;
}

router.get('/:entity', wrap(async (req, res) => {
  if (!getFields(req, res)) return;
  const [rows] = await pool.query('SELECT * FROM ?? ORDER BY sort_order, id', [req.params.entity]);
  res.json(rows);
}));

router.post('/:entity', wrap(async (req, res) => {
  const fields = getFields(req, res);
  if (!fields) return;
  const data = pick(req.body, fields);
  if (!Object.keys(data).length) return res.status(400).json({ error: 'Aucune donnée' });
  const [r] = await pool.query('INSERT INTO ?? SET ?', [req.params.entity, data]);
  res.status(201).json({ id: r.insertId });
}));

router.put('/:entity/:id', wrap(async (req, res) => {
  const fields = getFields(req, res);
  if (!fields) return;
  const id = getId(req, res);
  if (!id) return;
  const data = pick(req.body, fields);
  if (!Object.keys(data).length) return res.status(400).json({ error: 'Aucune donnée' });
  const [r] = await pool.query('UPDATE ?? SET ? WHERE id = ?', [req.params.entity, data, id]);
  if (!r.affectedRows) return res.status(404).json({ error: 'Élément introuvable' });
  res.json({ ok: true });
}));

router.delete('/:entity/:id', wrap(async (req, res) => {
  if (!getFields(req, res)) return;
  const id = getId(req, res);
  if (!id) return;
  await pool.query('DELETE FROM ?? WHERE id = ?', [req.params.entity, id]);
  res.json({ ok: true });
}));

module.exports = router;
__FIN__

cat > scripts/create-admin.js <<'__FIN__'
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
__FIN__

cat > server.js <<'__FIN__'
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const express = require('express');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const multer = require('multer');

const publicApi = require('./routes/public');
const adminApi = require('./routes/admin');
const { isAuthenticated, requireAuthPage } = require('./middleware/auth');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  console.error('❌ JWT_SECRET manquant ou trop court (32 caractères min.) dans le fichier .env');
  process.exit(1);
}

const app = express();
const PORT = process.env.PORT || 3000;
const isProd = process.env.NODE_ENV === 'production';
const ADMIN_PATH = '/' + (process.env.ADMIN_PATH || 'admin').replace(/^\/+|\/+$/g, '');

fs.mkdirSync(path.join(__dirname, 'uploads'), { recursive: true });

if (isProd) app.set('trust proxy', 1);
app.disable('x-powered-by');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      'default-src': ["'self'"],
      'script-src': ["'self'"],
      'style-src': ["'self'", 'https://fonts.googleapis.com'],
      'font-src': ["'self'", 'https://fonts.gstatic.com'],
      'img-src': ["'self'", 'data:'],
      'upgrade-insecure-requests': isProd ? [] : null,
    },
  },
}));

app.use(express.json({ limit: '100kb' }));
app.use(cookieParser());

app.use('/uploads', express.static(path.join(__dirname, 'uploads'), { dotfiles: 'deny' }));
app.use('/api/admin', adminApi);
app.use('/api', publicApi);

// Espace d'administration privé (aucun lien côté public)
const adminDir = path.join(__dirname, 'admin-ui');
const noIndex = (req, res, next) => {
  res.set('X-Robots-Tag', 'noindex, nofollow');
  res.set('Cache-Control', 'no-store');
  next();
};

app.use(`${ADMIN_PATH}/assets`, noIndex, express.static(path.join(adminDir, 'assets')));
app.get(ADMIN_PATH, (req, res) => res.redirect(`${ADMIN_PATH}/dashboard`));
app.get(`${ADMIN_PATH}/login`, noIndex, (req, res) =>
  isAuthenticated(req) ? res.redirect(`${ADMIN_PATH}/dashboard`) : res.sendFile(path.join(adminDir, 'login.html'))
);
app.get(`${ADMIN_PATH}/dashboard`, noIndex, requireAuthPage(ADMIN_PATH), (req, res) =>
  res.sendFile(path.join(adminDir, 'dashboard.html'))
);

// Site public
app.use(express.static(path.join(__dirname, 'public')));
app.use((req, res) => res.status(404).send('Page introuvable'));

// Gestion des erreurs
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ error: err.code === 'LIMIT_FILE_SIZE' ? 'Fichier trop volumineux (5 Mo max)' : err.message });
  }
  if (err.status === 400) return res.status(400).json({ error: err.message || 'Requête invalide' });
  if (['ER_BAD_NULL_ERROR', 'ER_DATA_TOO_LONG', 'WARN_DATA_TRUNCATED', 'ER_TRUNCATED_WRONG_VALUE_FOR_FIELD', 'ER_WARN_DATA_OUT_OF_RANGE'].includes(err.code)) {
    return res.status(400).json({ error: 'Données invalides : vérifie les champs obligatoires et leur longueur.' });
  }
  console.error(err);
  res.status(500).json({ error: 'Erreur serveur' });
});

app.listen(PORT, () => console.log(`🚀 Portfolio sur http://localhost:${PORT}`));
__FIN__

# ---------------------------------------------------------------- site public
cat > public/index.html <<'__FIN__'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Portfolio</title>
  <meta name="description" content="Portfolio — développement full-stack web et mobile">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <div class="blobs" aria-hidden="true"><span></span><span></span><span></span></div>

  <header class="nav" id="nav">
    <a href="#accueil" class="logo" id="logo">&lt;Portfolio /&gt;</a>
    <button class="burger" id="burger" aria-label="Ouvrir le menu"><span></span><span></span><span></span></button>
    <nav id="menu">
      <a href="#apropos">À propos</a>
      <a href="#competences">Compétences</a>
      <a href="#projets">Projets</a>
      <a href="#parcours">Parcours</a>
      <a href="#contact" class="btn-nav">Contact</a>
    </nav>
  </header>

  <main>
    <section id="accueil" class="hero">
      <div class="hero-text reveal">
        <p class="hello">👋 Bonjour, je suis</p>
        <h1 id="name" class="gradient-text">…</h1>
        <h2 id="title"></h2>
        <div class="hero-actions">
          <a href="#projets" class="btn btn-primary">Voir mes projets</a>
          <a href="#" id="cvBtn" class="btn btn-ghost hidden" target="_blank" rel="noopener">Télécharger mon CV</a>
        </div>
        <div class="socials" id="socials"></div>
      </div>
      <div class="hero-visual reveal">
        <div class="photo-ring">
          <img id="photo" class="hidden" alt="">
          <div id="initials" class="initials"></div>
        </div>
        <div class="floating f1">&lt;/&gt;</div>
        <div class="floating f2">{ }</div>
        <div class="floating f3">⚡</div>
      </div>
    </section>

    <section id="apropos" class="section">
      <h2 class="section-title reveal"><span>01.</span> À propos</h2>
      <div class="about reveal">
        <p id="bio"></p>
        <div class="stats">
          <div class="card"><strong id="statProjects">0</strong><span>Projets réalisés</span></div>
          <div class="card"><strong id="statSkills">0</strong><span>Technologies</span></div>
          <div class="card"><strong id="statExp">0</strong><span>Étapes de parcours</span></div>
        </div>
      </div>
    </section>

    <section id="competences" class="section">
      <h2 class="section-title reveal"><span>02.</span> Compétences</h2>
      <div class="skills-grid" id="skillsGrid"></div>
    </section>

    <section id="projets" class="section">
      <h2 class="section-title reveal"><span>03.</span> Projets</h2>
      <div class="filters reveal" id="filters"></div>
      <div class="projects-grid" id="projectsGrid"></div>
    </section>

    <section id="parcours" class="section">
      <h2 class="section-title reveal"><span>04.</span> Parcours</h2>
      <div class="timeline" id="timeline"></div>
    </section>

    <section id="contact" class="section">
      <h2 class="section-title reveal"><span>05.</span> Contact</h2>
      <div class="contact">
        <div class="card contact-info reveal">
          <h3>Travaillons <span class="gradient-text">ensemble</span> 🚀</h3>
          <p>Un projet, un stage ou une collaboration ? Écrivez-moi, je réponds rapidement.</p>
          <div id="contactLines"></div>
        </div>
        <form class="card contact-form reveal" id="contactForm" novalidate>
          <div class="row">
            <input name="name" placeholder="Votre nom" required maxlength="120">
            <input name="email" type="email" placeholder="Votre e-mail" required maxlength="150">
          </div>
          <input name="subject" placeholder="Sujet" maxlength="200">
          <textarea name="message" placeholder="Votre message…" required maxlength="5000"></textarea>
          <input name="website" class="hp" tabindex="-1" autocomplete="off" aria-hidden="true">
          <button class="btn btn-primary" type="submit">Envoyer le message</button>
          <p class="form-msg" id="formMsg"></p>
        </form>
      </div>
    </section>
  </main>

  <footer>© <span id="year"></span> <span id="footerName"></span> — Conçu et développé avec passion 💜</footer>

  <div class="modal" id="modal" role="dialog" aria-modal="true">
    <div class="modal-box card">
      <button class="modal-close" aria-label="Fermer">×</button>
      <div id="modalBody"></div>
    </div>
  </div>

  <script src="/js/main.js"></script>
</body>
</html>
__FIN__

cat > public/css/style.css <<'__FIN__'
:root {
  --bg: #120d2b;
  --bg2: #1b1440;
  --card: rgba(255, 255, 255, .06);
  --border: rgba(255, 255, 255, .12);
  --text: #f4f1ff;
  --muted: #b7b0d9;
  --pink: #ff4fd8;
  --orange: #ff9a3c;
  --cyan: #21d4fd;
  --violet: #8b5cf6;
  --grad: linear-gradient(135deg, var(--pink), var(--orange) 50%, var(--cyan));
  --radius: 20px;
}

* { margin: 0; padding: 0; box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { font-family: 'Poppins', sans-serif; background: var(--bg); color: var(--text); line-height: 1.7; overflow-x: hidden; }
a { color: inherit; text-decoration: none; }
img { max-width: 100%; display: block; }
.hidden { display: none !important; }

.blobs { position: fixed; inset: 0; z-index: -1; overflow: hidden; filter: blur(90px); opacity: .5; }
.blobs span { position: absolute; width: 45vw; height: 45vw; border-radius: 50%; animation: float 18s ease-in-out infinite alternate; }
.blobs span:nth-child(1) { background: var(--pink); top: -10%; left: -10%; }
.blobs span:nth-child(2) { background: var(--cyan); bottom: -15%; right: -10%; animation-delay: -6s; }
.blobs span:nth-child(3) { background: var(--violet); top: 40%; left: 40%; width: 30vw; height: 30vw; animation-delay: -12s; }
@keyframes float { to { transform: translate(8vw, 6vh) scale(1.15); } }

.gradient-text { background: var(--grad); background-size: 200% auto; -webkit-background-clip: text; background-clip: text; color: transparent; animation: shine 6s linear infinite; }
@keyframes shine { to { background-position: 200% center; } }

.nav { position: fixed; top: 0; left: 0; right: 0; z-index: 50; display: flex; justify-content: space-between; align-items: center; padding: 20px 6vw; transition: .3s; }
.nav.scrolled { background: rgba(18, 13, 43, .8); backdrop-filter: blur(14px); border-bottom: 1px solid var(--border); padding: 12px 6vw; }
.logo { font-family: 'Fira Code', monospace; font-weight: 500; font-size: 1.1rem; background: var(--grad); -webkit-background-clip: text; background-clip: text; color: transparent; }
#menu { display: flex; gap: 28px; align-items: center; }
#menu a { font-size: .95rem; color: var(--muted); transition: .2s; }
#menu a:hover { color: var(--text); }
#menu .btn-nav { padding: 8px 22px; border-radius: 50px; border: 1px solid var(--pink); color: var(--text); }
#menu .btn-nav:hover { background: var(--grad); border-color: transparent; }
.burger { display: none; position: relative; z-index: 60; background: none; border: 0; cursor: pointer; flex-direction: column; gap: 5px; }
.burger span { width: 26px; height: 2px; background: var(--text); transition: .3s; }
.burger.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
.burger.open span:nth-child(2) { opacity: 0; }
.burger.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }

.btn { display: inline-block; padding: 13px 30px; border-radius: 50px; font-weight: 600; transition: .3s; cursor: pointer; border: 0; font-family: inherit; font-size: 1rem; }
.btn-primary { background: var(--grad); color: #fff; box-shadow: 0 10px 30px rgba(255, 79, 216, .35); }
.btn-primary:hover { transform: translateY(-3px); box-shadow: 0 15px 40px rgba(255, 79, 216, .5); }
.btn-primary:disabled { opacity: .6; transform: none; }
.btn-ghost { border: 2px solid var(--border); color: var(--text); }
.btn-ghost:hover { border-color: var(--cyan); color: var(--cyan); }

.hero { min-height: 100vh; display: grid; grid-template-columns: 1.2fr 1fr; align-items: center; gap: 40px; padding: 120px 6vw 60px; max-width: 1400px; margin: 0 auto; }
.hello { color: var(--cyan); font-family: 'Fira Code', monospace; margin-bottom: 8px; }
.hero h1 { font-size: clamp(2.4rem, 6vw, 4.5rem); line-height: 1.1; font-weight: 800; }
.hero h2 { font-size: clamp(1.1rem, 2.4vw, 1.6rem); color: var(--muted); font-weight: 500; margin: 16px 0 32px; }
.hero-actions { display: flex; gap: 16px; flex-wrap: wrap; }
.socials { display: flex; gap: 14px; margin-top: 32px; }
.socials a { width: 46px; height: 46px; border-radius: 50%; display: grid; place-items: center; background: var(--card); border: 1px solid var(--border); font-size: .85rem; font-weight: 700; transition: .3s; }
.socials a:hover { background: var(--grad); transform: translateY(-4px); border-color: transparent; }
.hero-visual { position: relative; display: grid; place-items: center; min-height: 360px; }
.photo-ring { width: min(340px, 70vw); aspect-ratio: 1; border-radius: 50%; padding: 6px; background: var(--grad); box-shadow: 0 0 80px rgba(255, 79, 216, .45); animation: pulse 4s ease-in-out infinite; }
.photo-ring img, .initials { width: 100%; height: 100%; border-radius: 50%; object-fit: cover; background: var(--bg2); }
.initials { display: grid; place-items: center; font-size: clamp(3rem, 8vw, 5rem); font-weight: 800; }
@keyframes pulse { 50% { box-shadow: 0 0 120px rgba(33, 212, 253, .5); } }
.floating { position: absolute; font-family: 'Fira Code', monospace; font-size: 1.3rem; padding: 12px 16px; border-radius: 16px; background: var(--card); border: 1px solid var(--border); backdrop-filter: blur(10px); animation: bob 5s ease-in-out infinite; }
.f1 { top: 6%; left: 6%; color: var(--pink); }
.f2 { bottom: 10%; right: 4%; color: var(--cyan); animation-delay: -2s; }
.f3 { top: 16%; right: 8%; animation-delay: -3.5s; }
@keyframes bob { 50% { transform: translateY(-18px); } }

.section { padding: 100px 6vw; max-width: 1300px; margin: 0 auto; }
.section-title { font-size: clamp(1.8rem, 4vw, 2.6rem); margin-bottom: 50px; display: flex; align-items: center; gap: 14px; }
.section-title span { font-family: 'Fira Code', monospace; font-size: .6em; color: var(--pink); }
.section-title::after { content: ''; flex: 1; max-width: 300px; height: 2px; background: linear-gradient(90deg, var(--border), transparent); }
.card { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); backdrop-filter: blur(12px); }
.empty { color: var(--muted); text-align: center; padding: 40px; grid-column: 1 / -1; }

.about { display: grid; grid-template-columns: 1.5fr 1fr; gap: 40px; align-items: center; }
.about p { color: var(--muted); font-size: 1.08rem; white-space: pre-line; }
.stats { display: grid; gap: 16px; }
.stats .card { padding: 20px 26px; }
.stats strong { display: block; font-size: 2.4rem; line-height: 1.1; font-weight: 800; background: var(--grad); -webkit-background-clip: text; background-clip: text; color: transparent; }
.stats span { color: var(--muted); font-size: .9rem; }

.skills-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px; }
.skill-cat { padding: 28px; transition: .3s; }
.skill-cat:hover { border-color: rgba(33, 212, 253, .5); transform: translateY(-4px); }
.skill-cat h3 { margin-bottom: 20px; font-size: 1.15rem; }
.skill { margin-bottom: 16px; }
.skill-head { display: flex; justify-content: space-between; font-size: .92rem; margin-bottom: 6px; }
.skill-head span:last-child { color: var(--muted); font-family: 'Fira Code', monospace; font-size: .8rem; }
.bar { height: 8px; border-radius: 8px; background: rgba(255, 255, 255, .08); overflow: hidden; }
.bar i { display: block; height: 100%; width: 0; background: var(--grad); border-radius: 8px; transition: width 1.4s cubic-bezier(.2, .8, .2, 1); }

.filters { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 34px; }
.chip { padding: 8px 18px; border-radius: 50px; border: 1px solid var(--border); background: transparent; color: var(--muted); cursor: pointer; font-family: inherit; font-size: .88rem; transition: .25s; }
.chip.active, .chip:hover { background: var(--grad); color: #fff; border-color: transparent; }
.projects-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 28px; }
.project { overflow: hidden; cursor: pointer; transition: .35s; display: flex; flex-direction: column; animation: fadeUp .6s both; outline: none; }
.project:hover, .project:focus-visible { transform: translateY(-8px); border-color: rgba(255, 79, 216, .5); box-shadow: 0 20px 50px rgba(0, 0, 0, .35); }
@keyframes fadeUp { from { opacity: 0; transform: translateY(30px); } }
.project-img { height: 190px; background: var(--grad); position: relative; overflow: hidden; display: grid; place-items: center; font-size: 3rem; font-weight: 800; color: rgba(255, 255, 255, .9); }
.project-img img { width: 100%; height: 100%; object-fit: cover; transition: .5s; }
.project:hover .project-img img { transform: scale(1.08); }
.badge { position: absolute; top: 14px; left: 14px; padding: 4px 12px; border-radius: 50px; font-size: .75rem; font-weight: 600; background: rgba(18, 13, 43, .75); backdrop-filter: blur(6px); color: #fff; }
.project-body { padding: 24px; flex: 1; display: flex; flex-direction: column; }
.project-ctx { font-family: 'Fira Code', monospace; font-size: .78rem; color: var(--cyan); }
.project h3 { font-size: 1.25rem; margin: 6px 0 10px; }
.project p { color: var(--muted); font-size: .93rem; flex: 1; }
.tags { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 18px; }
.tags span { font-size: .75rem; padding: 4px 10px; border-radius: 8px; background: rgba(139, 92, 246, .2); color: #dccdff; font-family: 'Fira Code', monospace; }

.modal { position: fixed; inset: 0; z-index: 100; background: rgba(8, 5, 20, .75); backdrop-filter: blur(8px); display: grid; place-items: center; padding: 20px; opacity: 0; pointer-events: none; transition: .3s; }
.modal.open { opacity: 1; pointer-events: auto; }
.modal-box { max-width: 760px; width: 100%; max-height: 90vh; overflow: auto; background: var(--bg2); position: relative; transform: translateY(30px); transition: .3s; }
.modal.open .modal-box { transform: none; }
.modal-close { position: absolute; top: 14px; right: 14px; width: 40px; height: 40px; border-radius: 50%; border: 0; background: rgba(0, 0, 0, .5); color: #fff; font-size: 1.5rem; cursor: pointer; z-index: 2; }
.modal-img { height: 280px; background: var(--grad); }
.modal-img:empty { height: 110px; }
.modal-img img { width: 100%; height: 100%; object-fit: cover; }
.modal-content { padding: 30px; }
.modal-content h3 { font-size: 1.7rem; margin: 6px 0 14px; }
.modal-content p { color: var(--muted); white-space: pre-line; }
.modal-links { display: flex; gap: 12px; margin-top: 26px; flex-wrap: wrap; }

.timeline { position: relative; max-width: 850px; margin: 0 auto; }
.timeline::before { content: ''; position: absolute; left: 17px; top: 0; bottom: 0; width: 3px; background: var(--grad); border-radius: 3px; }
.tl-item { position: relative; padding-left: 64px; margin-bottom: 34px; }
.tl-dot { position: absolute; left: 0; top: 22px; width: 37px; height: 37px; border-radius: 50%; background: var(--bg); border: 3px solid var(--pink); display: grid; place-items: center; font-size: .95rem; }
.tl-card { padding: 22px 26px; transition: .3s; }
.tl-card:hover { border-color: rgba(255, 154, 60, .5); }
.tl-period { font-family: 'Fira Code', monospace; font-size: .8rem; color: var(--orange); }
.tl-card h3 { font-size: 1.15rem; margin: 4px 0; }
.tl-org { color: var(--cyan); font-size: .92rem; margin-bottom: 8px; }
.tl-card p { color: var(--muted); font-size: .93rem; white-space: pre-line; }

.contact { display: grid; grid-template-columns: 1fr 1.4fr; gap: 30px; }
.contact-info { padding: 34px; }
.contact-info h3 { font-size: 1.5rem; margin-bottom: 12px; }
.contact-info > p { color: var(--muted); margin-bottom: 26px; }
.info-line { display: flex; gap: 14px; align-items: center; margin-bottom: 16px; }
.info-line i { width: 42px; height: 42px; border-radius: 12px; background: var(--grad); display: grid; place-items: center; font-style: normal; flex-shrink: 0; }
.info-line a, .info-line span { word-break: break-word; }
.info-line a:hover { color: var(--cyan); }
.contact-form { padding: 34px; display: grid; gap: 16px; position: relative; }
.row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.contact-form input, .contact-form textarea { width: 100%; padding: 14px 18px; border-radius: 14px; border: 1px solid var(--border); background: rgba(255, 255, 255, .04); color: var(--text); font-family: inherit; font-size: .95rem; transition: .25s; }
.contact-form input::placeholder, .contact-form textarea::placeholder { color: #8d86b5; }
.contact-form input:focus, .contact-form textarea:focus { outline: none; border-color: var(--pink); box-shadow: 0 0 0 4px rgba(255, 79, 216, .15); }
.contact-form textarea { min-height: 150px; resize: vertical; }
.contact-form .hp { position: absolute; left: -9999px; width: 1px; height: 1px; }
.form-msg { font-size: .9rem; min-height: 1.2em; }
.form-msg.ok { color: #4ade80; }
.form-msg.err { color: #f87171; }

footer { text-align: center; padding: 40px 6vw; color: var(--muted); border-top: 1px solid var(--border); font-size: .9rem; }

.reveal { opacity: 0; transform: translateY(40px); transition: opacity .8s, transform .8s; }
.reveal.visible { opacity: 1; transform: none; }

@media (max-width: 900px) {
  .hero { grid-template-columns: 1fr; text-align: center; padding-top: 110px; }
  .hero-visual { order: -1; min-height: 300px; }
  .hero-actions, .socials { justify-content: center; }
  .about, .contact { grid-template-columns: 1fr; }
  .stats { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 768px) {
  .burger { display: flex; }
  #menu { position: fixed; top: 0; right: -100%; height: 100vh; width: 75%; flex-direction: column; justify-content: center; background: rgba(18, 13, 43, .97); backdrop-filter: blur(14px); transition: .4s; }
  #menu.open { right: 0; }
  #menu a { font-size: 1.1rem; }
  .row, .stats { grid-template-columns: 1fr; }
  .projects-grid { grid-template-columns: 1fr; }
  .section { padding: 80px 5vw; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation: none !important; transition: none !important; }
  .reveal { opacity: 1; transform: none; }
}
__FIN__

cat > public/js/main.js <<'__FIN__'
const $ = (s) => document.querySelector(s);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const safeUrl = (u) => (/^(https?:\/\/|\/uploads\/)/i.test(u || '') ? u : '');
const techs = (p) => (p.tech || '').split(',').map((t) => t.trim()).filter(Boolean);
const initialsOf = (txt) => String(txt || '').split(/\s+/).filter(Boolean).map((w) => w[0]).slice(0, 2).join('').toUpperCase();
const ICONS = { formation: '🎓', stage: '💼', experience: '⭐', projet: '🚀' };
let projects = [];

const nav = $('#nav');
const burger = $('#burger');
const menu = $('#menu');
addEventListener('scroll', () => nav.classList.toggle('scrolled', scrollY > 40));
burger.addEventListener('click', () => {
  burger.classList.toggle('open');
  menu.classList.toggle('open');
});
menu.addEventListener('click', (e) => {
  if (e.target.tagName === 'A') {
    burger.classList.remove('open');
    menu.classList.remove('open');
  }
});

function countUp(el, n) {
  let i = 0;
  const step = Math.max(1, Math.ceil(n / 30));
  const t = setInterval(() => {
    i = Math.min(n, i + step);
    el.textContent = i;
    if (i >= n) clearInterval(t);
  }, 40);
}

const io = new IntersectionObserver((entries) => {
  entries.forEach((en) => {
    if (!en.isIntersecting) return;
    const el = en.target;
    el.classList.add('visible');
    el.querySelectorAll('.bar i').forEach((b) => { b.style.width = b.dataset.level + '%'; });
    el.querySelectorAll('[data-count]').forEach((c) => countUp(c, Number(c.dataset.count)));
    io.unobserve(el);
  });
}, { threshold: 0.15 });

const observe = () => document.querySelectorAll('.reveal:not(.visible)').forEach((el) => io.observe(el));

function renderProfile(p) {
  const name = p.full_name || 'Mon Portfolio';
  document.title = `${name} — Portfolio`;
  $('#name').textContent = name;
  $('#title').textContent = p.title || '';
  $('#bio').textContent = p.bio || '';
  $('#logo').textContent = `<${name.split(' ')[0]} />`;
  $('#footerName').textContent = name;
  $('#year').textContent = new Date().getFullYear();

  const photo = safeUrl(p.photo);
  if (photo) {
    $('#photo').src = photo;
    $('#photo').alt = name;
    $('#photo').classList.remove('hidden');
    $('#initials').classList.add('hidden');
  } else {
    $('#initials').textContent = initialsOf(name);
  }

  const cv = safeUrl(p.cv);
  if (cv) {
    $('#cvBtn').href = cv;
    $('#cvBtn').classList.remove('hidden');
  }

  const socials = [
    [safeUrl(p.github), 'GH', 'GitHub'],
    [safeUrl(p.linkedin), 'in', 'LinkedIn'],
    [p.email ? `mailto:${p.email}` : '', '@', 'E-mail'],
  ].filter((s) => s[0]);
  $('#socials').innerHTML = socials
    .map(([u, t, l]) => `<a href="${esc(u)}" target="_blank" rel="noopener" aria-label="${l}" title="${l}">${t}</a>`)
    .join('');

  const lines = [
    ['✉️', p.email, p.email ? `mailto:${p.email}` : ''],
    ['📞', p.phone, p.phone ? `tel:${String(p.phone).replace(/\s/g, '')}` : ''],
    ['📍', p.location, ''],
  ].filter((l) => l[1]);
  $('#contactLines').innerHTML = lines
    .map(([i, t, h]) => `<div class="info-line"><i>${i}</i>${h ? `<a href="${esc(h)}">${esc(t)}</a>` : `<span>${esc(t)}</span>`}</div>`)
    .join('');
}

function renderSkills(skills) {
  const groups = {};
  skills.forEach((s) => { (groups[s.category || 'Autres'] ||= []).push(s); });
  $('#skillsGrid').innerHTML = Object.entries(groups).map(([cat, list]) => `
    <div class="card skill-cat reveal">
      <h3>${esc(cat)}</h3>
      ${list.map((s) => {
        const lvl = Math.min(100, Math.max(0, Number(s.level) || 0));
        return `<div class="skill">
          <div class="skill-head"><span>${esc(s.name)}</span><span>${lvl}%</span></div>
          <div class="bar"><i data-level="${lvl}"></i></div>
        </div>`;
      }).join('')}
    </div>`).join('') || '<p class="empty">Bientôt disponible.</p>';
}

function renderFilters() {
  const count = {};
  projects.forEach((p) => techs(p).forEach((t) => { count[t] = (count[t] || 0) + 1; }));
  const top = Object.entries(count).sort((a, b) => b[1] - a[1]).slice(0, 8).map((e) => e[0]);
  $('#filters').innerHTML = ['Tous', ...top]
    .map((t, i) => `<button class="chip ${i ? '' : 'active'}" data-filter="${esc(t)}">${esc(t)}</button>`)
    .join('');
}

function renderProjects(filter) {
  const list = filter === 'Tous' ? projects : projects.filter((p) => techs(p).includes(filter));
  $('#projectsGrid').innerHTML = list.map((p) => {
    const img = safeUrl(p.image);
    return `<article class="card project" data-id="${p.id}" tabindex="0">
      <div class="project-img">
        ${img ? `<img src="${esc(img)}" alt="${esc(p.title)}" loading="lazy">` : esc(initialsOf(p.title))}
        ${p.featured ? '<span class="badge">★ En vedette</span>' : ''}
      </div>
      <div class="project-body">
        ${p.context ? `<span class="project-ctx">${esc(p.context)}</span>` : ''}
        <h3>${esc(p.title)}</h3>
        <p>${esc(p.summary)}</p>
        <div class="tags">${techs(p).slice(0, 5).map((t) => `<span>${esc(t)}</span>`).join('')}</div>
      </div>
    </article>`;
  }).join('') || '<p class="empty">Aucun projet pour ce filtre.</p>';
}

$('#filters').addEventListener('click', (e) => {
  const b = e.target.closest('.chip');
  if (!b) return;
  document.querySelectorAll('.chip').forEach((c) => c.classList.toggle('active', c === b));
  renderProjects(b.dataset.filter);
});

function openProject(id) {
  const p = projects.find((x) => x.id === id);
  if (!p) return;
  const img = safeUrl(p.image);
  const demo = safeUrl(p.demo_url);
  const repo = safeUrl(p.repo_url);
  $('#modalBody').innerHTML = `
    <div class="modal-img">${img ? `<img src="${esc(img)}" alt="${esc(p.title)}">` : ''}</div>
    <div class="modal-content">
      ${p.context ? `<span class="project-ctx">${esc(p.context)}</span>` : ''}
      <h3>${esc(p.title)}</h3>
      <p>${esc(p.description || p.summary)}</p>
      <div class="tags">${techs(p).map((t) => `<span>${esc(t)}</span>`).join('')}</div>
      ${demo || repo ? `<div class="modal-links">
        ${demo ? `<a class="btn btn-primary" href="${esc(demo)}" target="_blank" rel="noopener">Voir la démo ↗</a>` : ''}
        ${repo ? `<a class="btn btn-ghost" href="${esc(repo)}" target="_blank" rel="noopener">Code source ↗</a>` : ''}
      </div>` : ''}
    </div>`;
  $('#modal').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeModal() {
  $('#modal').classList.remove('open');
  document.body.style.overflow = '';
}

$('#projectsGrid').addEventListener('click', (e) => {
  const c = e.target.closest('.project');
  if (c) openProject(Number(c.dataset.id));
});
$('#projectsGrid').addEventListener('keydown', (e) => {
  const c = e.target.closest('.project');
  if (c && e.key === 'Enter') openProject(Number(c.dataset.id));
});
$('#modal').addEventListener('click', (e) => {
  if (e.target.id === 'modal' || e.target.closest('.modal-close')) closeModal();
});
addEventListener('keydown', (e) => { if (e.key === 'Escape') closeModal(); });

function renderTimeline(items) {
  $('#timeline').innerHTML = items.map((x) => `
    <div class="tl-item reveal">
      <span class="tl-dot">${ICONS[x.type] || '•'}</span>
      <div class="card tl-card">
        ${x.period ? `<span class="tl-period">${esc(x.period)}</span>` : ''}
        <h3>${esc(x.title)}</h3>
        ${x.organization ? `<div class="tl-org">${esc(x.organization)}</div>` : ''}
        ${x.description ? `<p>${esc(x.description)}</p>` : ''}
      </div>
    </div>`).join('') || '<p class="empty">Bientôt disponible.</p>';
}

$('#contactForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const f = e.target;
  const msg = $('#formMsg');
  const btn = f.querySelector('button');
  msg.className = 'form-msg';
  msg.textContent = '';
  btn.disabled = true;
  btn.textContent = 'Envoi…';
  try {
    const res = await fetch('/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(new FormData(f))),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || 'Envoi impossible pour le moment.');
    f.reset();
    msg.classList.add('ok');
    msg.textContent = 'Merci ! Votre message a bien été envoyé.';
  } catch (err) {
    msg.classList.add('err');
    msg.textContent = err.message;
  } finally {
    btn.disabled = false;
    btn.textContent = 'Envoyer le message';
  }
});

(async function load() {
  try {
    const res = await fetch('/api/portfolio');
    if (!res.ok) throw new Error();
    const d = await res.json();
    projects = d.projects || [];
    renderProfile(d.profile || {});
    renderSkills(d.skills || []);
    renderFilters();
    renderProjects('Tous');
    renderTimeline(d.experiences || []);
    $('#statProjects').dataset.count = projects.length;
    $('#statSkills').dataset.count = (d.skills || []).length;
    $('#statExp').dataset.count = (d.experiences || []).length;
  } catch {
    $('#bio').textContent = 'Impossible de charger le contenu pour le moment.';
  } finally {
    observe();
  }
})();
__FIN__

# ---------------------------------------------------------------- admin privé
cat > admin-ui/login.html <<'__FIN__'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, nofollow">
  <title>Connexion</title>
  <link rel="stylesheet" href="assets/admin.css">
</head>
<body class="login-page">
  <form id="loginForm" class="login-box">
    <h1>Espace privé</h1>
    <p class="muted">Connecte-toi pour gérer ton portfolio.</p>
    <label>Identifiant<input name="username" required autocomplete="username"></label>
    <label>Mot de passe<input type="password" name="password" required autocomplete="current-password"></label>
    <button class="btn" type="submit">Se connecter</button>
    <p id="err" class="err"></p>
  </form>
  <script src="assets/login.js"></script>
</body>
</html>
__FIN__

cat > admin-ui/assets/login.js <<'__FIN__'
document.getElementById('loginForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const f = e.target;
  const err = document.getElementById('err');
  const btn = f.querySelector('button');
  err.textContent = '';
  btn.disabled = true;
  try {
    const res = await fetch('/api/admin/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: f.username.value.trim(), password: f.password.value }),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || 'Échec de la connexion');
    location.href = 'dashboard';
  } catch (x) {
    err.textContent = x.message;
  } finally {
    btn.disabled = false;
  }
});
__FIN__

cat > admin-ui/dashboard.html <<'__FIN__'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="robots" content="noindex, nofollow">
  <title>Administration</title>
  <link rel="stylesheet" href="assets/admin.css">
</head>
<body>
  <aside class="sidebar" id="sidebar">
    <div class="brand">Portfolio<span>admin</span></div>
    <nav>
      <button data-tab="profile" class="active">👤 Mon profil</button>
      <button data-tab="projects">🚀 Projets</button>
      <button data-tab="skills">⚡ Compétences</button>
      <button data-tab="experiences">🎓 Parcours</button>
      <button data-tab="messages">✉️ Messages <span id="msgBadge" class="badge hidden"></span></button>
      <button data-tab="security">🔒 Sécurité</button>
    </nav>
    <div class="side-foot">
      <span id="who"></span>
      <a href="/" target="_blank" rel="noopener">Voir le site ↗</a>
      <button id="logoutBtn" class="link-btn danger" type="button">Déconnexion</button>
    </div>
  </aside>

  <main class="main">
    <header class="topbar">
      <button id="menuBtn" class="menu-btn" type="button" aria-label="Menu">☰</button>
      <h1 id="pageTitle">Mon profil</h1>
    </header>
    <section id="view"></section>
  </main>

  <div class="modal" id="modal">
    <div class="modal-box">
      <h2 id="modalTitle"></h2>
      <form id="modalForm" class="grid-form"></form>
    </div>
  </div>

  <div id="toast" class="toast"></div>
  <script src="assets/admin.js"></script>
</body>
</html>
__FIN__

cat > admin-ui/assets/admin.js <<'__FIN__'
const $ = (s, el = document) => el.querySelector(s);
const $$ = (s, el = document) => [...el.querySelectorAll(s)];
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function api(url, opts = {}) {
  const isForm = opts.body instanceof FormData;
  const res = await fetch('/api/admin' + url, { ...opts, headers: isForm ? {} : { 'Content-Type': 'application/json' } });
  if (res.status === 401) {
    location.href = 'login';
    throw new Error('Session expirée');
  }
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || 'Erreur serveur');
  return data;
}
const send = (url, method, body) => api(url, { method, body: body ? JSON.stringify(body) : undefined });

function toast(msg, type = 'ok') {
  const t = $('#toast');
  t.textContent = msg;
  t.className = `toast show ${type}`;
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => { t.className = 'toast'; }, 2800);
}

const IMG = 'image/png,image/jpeg,image/webp,image/gif';

const PROFILE_FIELDS = [
  { k: 'full_name', l: 'Nom complet' },
  { k: 'title', l: 'Titre (ex : Développeuse Full-Stack)' },
  { k: 'bio', l: 'Présentation', t: 'textarea' },
  { k: 'email', l: 'E-mail', t: 'email' },
  { k: 'phone', l: 'Téléphone' },
  { k: 'location', l: 'Localisation' },
  { k: 'github', l: 'Lien GitHub', t: 'url' },
  { k: 'linkedin', l: 'Lien LinkedIn', t: 'url' },
  { k: 'photo', l: 'Photo de profil', t: 'file', accept: IMG },
  { k: 'cv', l: 'CV (PDF)', t: 'file', accept: 'application/pdf' },
];

const SCHEMAS = {
  projects: {
    add: 'Ajouter un projet',
    cols: [['title', 'Titre'], ['context', 'Contexte'], ['tech', 'Technologies']],
    fields: [
      { k: 'title', l: 'Titre *', req: true },
      { k: 'context', l: 'Contexte (ex : Stage — Albatres Ingénierie)' },
      { k: 'summary', l: 'Résumé court (affiché sur la carte)', t: 'textarea' },
      { k: 'description', l: 'Description détaillée (affichée dans la fenêtre)', t: 'textarea' },
      { k: 'tech', l: 'Technologies (séparées par des virgules)' },
      { k: 'demo_url', l: 'Lien démo', t: 'url' },
      { k: 'repo_url', l: 'Lien GitHub', t: 'url' },
      { k: 'image', l: 'Image de couverture', t: 'file', accept: IMG },
      { k: 'sort_order', l: 'Ordre d’affichage', t: 'number' },
      { k: 'featured', l: 'Mettre en vedette', t: 'check' },
    ],
  },
  skills: {
    add: 'Ajouter une compétence',
    cols: [['name', 'Nom'], ['category', 'Catégorie'], ['level', 'Niveau %']],
    fields: [
      { k: 'name', l: 'Nom *', req: true },
      { k: 'category', l: 'Catégorie (Backend, Frontend, Mobile…)' },
      { k: 'level', l: 'Niveau (0 à 100)', t: 'number', min: 0, max: 100 },
      { k: 'sort_order', l: 'Ordre d’affichage', t: 'number' },
    ],
  },
  experiences: {
    add: 'Ajouter une étape',
    cols: [['period', 'Période'], ['title', 'Intitulé'], ['organization', 'Structure']],
    fields: [
      { k: 'type', l: 'Type', t: 'select', opts: [['formation', 'Formation'], ['stage', 'Stage'], ['experience', 'Expérience'], ['projet', 'Projet']] },
      { k: 'period', l: 'Période (ex : Juil. — Sept. 2026)' },
      { k: 'title', l: 'Intitulé *', req: true },
      { k: 'organization', l: 'Établissement / entreprise' },
      { k: 'description', l: 'Description', t: 'textarea' },
      { k: 'sort_order', l: 'Ordre d’affichage', t: 'number' },
    ],
  },
};

const TITLES = { profile: 'Mon profil', projects: 'Projets', skills: 'Compétences', experiences: 'Parcours', messages: 'Messages', security: 'Sécurité' };

function fieldHtml(f, value) {
  const v = value ?? '';
  const req = f.req ? 'required' : '';
  switch (f.t) {
    case 'textarea':
      return `<label class="full">${f.l}<textarea name="${f.k}" ${req}>${esc(v)}</textarea></label>`;
    case 'number':
      return `<label>${f.l}<input type="number" name="${f.k}" value="${esc(v)}" ${f.min != null ? `min="${f.min}"` : ''} ${f.max != null ? `max="${f.max}"` : ''}></label>`;
    case 'check':
      return `<label class="check"><input type="checkbox" name="${f.k}" ${Number(v) ? 'checked' : ''}> ${f.l}</label>`;
    case 'select':
      return `<label>${f.l}<select name="${f.k}">${f.opts.map(([val, lab]) => `<option value="${val}" ${val === v ? 'selected' : ''}>${lab}</option>`).join('')}</select></label>`;
    case 'file': {
      const isImg = v && !/\.pdf$/i.test(v);
      return `<div class="file-field full">
        <span>${f.l}</span>
        <input type="hidden" name="${f.k}" value="${esc(v)}">
        <div class="file-row">
          <img class="thumb ${isImg ? '' : 'hidden'}" ${isImg ? `src="${esc(v)}"` : ''} alt="">
          <input type="file" data-upload accept="${f.accept}">
          <a class="link-btn file-current ${v ? '' : 'hidden'}" href="${esc(v || '#')}" target="_blank" rel="noopener">Ouvrir</a>
          <button type="button" class="link-btn danger ${v ? '' : 'hidden'}" data-clear>Retirer</button>
        </div>
      </div>`;
    }
    default:
      return `<label>${f.l}<input type="${f.t || 'text'}" name="${f.k}" value="${esc(v)}" ${req}></label>`;
  }
}

function collect(form, fields) {
  const out = {};
  for (const f of fields) {
    const el = form.elements[f.k];
    if (!el) continue;
    if (f.t === 'check') out[f.k] = el.checked ? 1 : 0;
    else if (f.t === 'number') out[f.k] = el.value === '' ? 0 : Number(el.value);
    else out[f.k] = el.value.trim();
  }
  return out;
}

function setFile(box, url) {
  $('input[type=hidden]', box).value = url;
  const link = $('.file-current', box);
  link.href = url || '#';
  link.classList.toggle('hidden', !url);
  $('[data-clear]', box).classList.toggle('hidden', !url);
  const img = $('.thumb', box);
  const isImg = url && !/\.pdf$/i.test(url);
  if (isImg) img.src = url;
  img.classList.toggle('hidden', !isImg);
  if (!url) $('input[type=file]', box).value = '';
}

function bindUploads(form) {
  $$('input[data-upload]', form).forEach((inp) => inp.addEventListener('change', async () => {
    const file = inp.files[0];
    if (!file) return;
    const box = inp.closest('.file-field');
    const fd = new FormData();
    fd.append('file', file);
    box.classList.add('loading');
    try {
      const { url } = await api('/upload', { method: 'POST', body: fd });
      setFile(box, url);
      toast('Fichier envoyé');
    } catch (x) {
      toast(x.message, 'err');
      inp.value = '';
    } finally {
      box.classList.remove('loading');
    }
  }));
  $$('[data-clear]', form).forEach((b) => b.addEventListener('click', () => setFile(b.closest('.file-field'), '')));
}

async function show(tab) {
  $$('[data-tab]').forEach((b) => b.classList.toggle('active', b.dataset.tab === tab));
  $('#pageTitle').textContent = TITLES[tab];
  $('#sidebar').classList.remove('open');
  const v = $('#view');
  v.innerHTML = '<p class="muted">Chargement…</p>';
  try {
    if (tab === 'profile') await renderProfile();
    else if (tab === 'messages') await renderMessages();
    else if (tab === 'security') renderSecurity();
    else await renderList(tab);
  } catch (e) {
    v.innerHTML = `<p class="err">${esc(e.message)}</p>`;
  }
}

$$('[data-tab]').forEach((b) => b.addEventListener('click', () => show(b.dataset.tab)));
$('#menuBtn').addEventListener('click', () => $('#sidebar').classList.toggle('open'));
$('#logoutBtn').addEventListener('click', async () => {
  try { await send('/logout', 'POST'); } finally { location.href = 'login'; }
});

async function renderProfile() {
  const p = await api('/profile');
  $('#view').innerHTML = `<form id="profileForm" class="panel grid-form">
    ${PROFILE_FIELDS.map((f) => fieldHtml(f, p[f.k])).join('')}
    <div class="actions full"><button class="btn" type="submit">Enregistrer</button></div>
  </form>`;
  const form = $('#profileForm');
  bindUploads(form);
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    try {
      await send('/profile', 'PUT', collect(form, PROFILE_FIELDS));
      toast('Profil enregistré');
    } catch (x) {
      toast(x.message, 'err');
    }
  });
}

async function renderList(entity) {
  const s = SCHEMAS[entity];
  const rows = await api('/' + entity);
  const v = $('#view');
  v.innerHTML = `
    <div class="toolbar">
      <span class="muted">${rows.length} élément(s)</span>
      <button class="btn" id="addBtn" type="button">+ ${s.add}</button>
    </div>
    ${rows.length ? `<div class="panel table-wrap"><table>
      <thead><tr>${s.cols.map((c) => `<th>${c[1]}</th>`).join('')}<th></th></tr></thead>
      <tbody>${rows.map((r) => `<tr>
        ${s.cols.map(([k]) => `<td>${esc(r[k])}</td>`).join('')}
        <td><div class="row-actions">
          <button class="link-btn" type="button" data-edit="${r.id}">Modifier</button>
          <button class="link-btn danger" type="button" data-del="${r.id}">Supprimer</button>
        </div></td>
      </tr>`).join('')}</tbody>
    </table></div>` : '<div class="panel empty">Aucun élément pour l’instant.</div>'}`;

  $('#addBtn').addEventListener('click', () => openForm(entity));
  $$('[data-edit]', v).forEach((b) => b.addEventListener('click', () =>
    openForm(entity, rows.find((r) => r.id === Number(b.dataset.edit)))));
  $$('[data-del]', v).forEach((b) => b.addEventListener('click', async () => {
    if (!confirm('Supprimer définitivement cet élément ?')) return;
    try {
      await send(`/${entity}/${b.dataset.del}`, 'DELETE');
      toast('Élément supprimé');
      renderList(entity);
    } catch (x) {
      toast(x.message, 'err');
    }
  }));
}

function openForm(entity, row = {}) {
  const s = SCHEMAS[entity];
  $('#modalTitle').textContent = row.id ? 'Modifier' : s.add;
  const form = $('#modalForm');
  form.innerHTML = s.fields.map((f) => fieldHtml(f, row[f.k])).join('') + `
    <div class="actions full">
      <button type="button" class="btn ghost" data-close>Annuler</button>
      <button class="btn" type="submit">${row.id ? 'Enregistrer' : 'Ajouter'}</button>
    </div>`;
  bindUploads(form);
  form.onsubmit = async (e) => {
    e.preventDefault();
    try {
      const data = collect(form, s.fields);
      if (row.id) await send(`/${entity}/${row.id}`, 'PUT', data);
      else await send(`/${entity}`, 'POST', data);
      closeModal();
      toast('Enregistré');
      renderList(entity);
    } catch (x) {
      toast(x.message, 'err');
    }
  };
  $('#modal').classList.add('open');
}

function closeModal() { $('#modal').classList.remove('open'); }
$('#modal').addEventListener('click', (e) => {
  if (e.target.id === 'modal' || e.target.closest('[data-close]')) closeModal();
});
addEventListener('keydown', (e) => { if (e.key === 'Escape') closeModal(); });

function updateBadge(list) {
  const n = list.filter((m) => !m.is_read).length;
  const b = $('#msgBadge');
  b.textContent = n;
  b.classList.toggle('hidden', !n);
}

async function renderMessages() {
  const list = await api('/messages');
  updateBadge(list);
  const v = $('#view');
  if (!list.length) {
    v.innerHTML = '<div class="panel empty">Aucun message reçu.</div>';
    return;
  }
  v.innerHTML = list.map((m) => `
    <article class="panel msg ${m.is_read ? '' : 'unread'}">
      <header>
        <div><strong>${esc(m.name)}</strong><a href="mailto:${esc(m.email)}">${esc(m.email)}</a></div>
        <time>${new Date(m.created_at).toLocaleString('fr-FR')}</time>
      </header>
      ${m.subject ? `<h4>${esc(m.subject)}</h4>` : ''}
      <p>${esc(m.message)}</p>
      <div class="row-actions start">
        <a class="link-btn" href="mailto:${esc(m.email)}?subject=${encodeURIComponent('Re : ' + (m.subject || 'Votre message'))}">Répondre</a>
        ${m.is_read ? '' : `<button class="link-btn" type="button" data-read="${m.id}">Marquer comme lu</button>`}
        <button class="link-btn danger" type="button" data-delmsg="${m.id}">Supprimer</button>
      </div>
    </article>`).join('');

  $$('[data-read]', v).forEach((b) => b.addEventListener('click', async () => {
    try { await send(`/messages/${b.dataset.read}/read`, 'PATCH'); renderMessages(); } catch (x) { toast(x.message, 'err'); }
  }));
  $$('[data-delmsg]', v).forEach((b) => b.addEventListener('click', async () => {
    if (!confirm('Supprimer ce message ?')) return;
    try { await send(`/messages/${b.dataset.delmsg}`, 'DELETE'); toast('Message supprimé'); renderMessages(); } catch (x) { toast(x.message, 'err'); }
  }));
}

function renderSecurity() {
  $('#view').innerHTML = `<form id="pwdForm" class="panel grid-form narrow">
    <label class="full">Mot de passe actuel<input type="password" name="current" required autocomplete="current-password"></label>
    <label class="full">Nouveau mot de passe (8 caractères min.)<input type="password" name="next" minlength="8" required autocomplete="new-password"></label>
    <label class="full">Confirmer le nouveau mot de passe<input type="password" name="confirm" minlength="8" required autocomplete="new-password"></label>
    <div class="actions full"><button class="btn" type="submit">Changer le mot de passe</button></div>
  </form>`;
  $('#pwdForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const f = e.target;
    if (f.next.value !== f.confirm.value) return toast('Les mots de passe ne correspondent pas', 'err');
    try {
      await send('/password', 'PUT', { current: f.current.value, next: f.next.value });
      f.reset();
      toast('Mot de passe modifié');
    } catch (x) {
      toast(x.message, 'err');
    }
  });
}

(async () => {
  try {
    const me = await api('/me');
    $('#who').textContent = `Connecté : ${me.username}`;
    updateBadge(await api('/messages'));
  } catch { /* redirection gérée par api() */ }
  show('profile');
})();
__FIN__

cat > admin-ui/assets/admin.css <<'__FIN__'
:root {
  --bg: #f5f3ff;
  --side: #16112f;
  --card: #fff;
  --text: #1f1a3a;
  --muted: #6b6790;
  --border: #e6e1fa;
  --pink: #ff4fd8;
  --violet: #8b5cf6;
  --danger: #e11d48;
  --grad: linear-gradient(135deg, #ff4fd8, #ff9a3c 50%, #21d4fd);
}

* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif; background: var(--bg); color: var(--text); display: flex; min-height: 100vh; }
.hidden { display: none !important; }
.muted { color: var(--muted); }
.err { color: var(--danger); font-size: .9rem; min-height: 1.2em; }

.sidebar { width: 250px; background: var(--side); color: #fff; display: flex; flex-direction: column; padding: 24px 16px; position: fixed; inset: 0 auto 0 0; z-index: 30; transition: transform .3s; }
.brand { font-weight: 800; font-size: 1.3rem; margin: 0 10px 30px; background: var(--grad); -webkit-background-clip: text; background-clip: text; color: transparent; }
.brand span { font-size: .75rem; margin-left: 6px; -webkit-text-fill-color: #a59fd0; }
.sidebar nav { display: flex; flex-direction: column; gap: 4px; flex: 1; }
.sidebar nav button { all: unset; cursor: pointer; padding: 12px 14px; border-radius: 12px; color: #cfc9f2; display: flex; align-items: center; gap: 10px; transition: .2s; }
.sidebar nav button:hover { background: rgba(255, 255, 255, .07); color: #fff; }
.sidebar nav button.active { background: var(--grad); color: #fff; font-weight: 600; }
.badge { margin-left: auto; background: var(--pink); color: #fff; border-radius: 20px; font-size: .72rem; padding: 2px 8px; }
.active .badge { background: #fff; color: var(--violet); }
.side-foot { display: flex; flex-direction: column; gap: 10px; padding: 16px 10px 0; border-top: 1px solid rgba(255, 255, 255, .1); font-size: .88rem; }
.side-foot a { color: #cfc9f2; text-decoration: none; }
#who { color: #8f89bd; }

.main { flex: 1; margin-left: 250px; padding: 30px 36px; min-width: 0; }
.topbar { display: flex; align-items: center; gap: 14px; margin-bottom: 26px; }
.topbar h1 { font-size: 1.6rem; }
.menu-btn { display: none; border: 0; background: var(--card); width: 42px; height: 42px; border-radius: 12px; font-size: 1.2rem; cursor: pointer; box-shadow: 0 4px 14px rgba(80, 60, 180, .1); }
.panel { background: var(--card); border: 1px solid var(--border); border-radius: 18px; padding: 26px; box-shadow: 0 6px 24px rgba(80, 60, 180, .06); }
.empty { text-align: center; color: var(--muted); }

.grid-form { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.grid-form.narrow { max-width: 520px; }
.grid-form label, .file-field { display: flex; flex-direction: column; gap: 6px; font-size: .88rem; font-weight: 600; color: var(--muted); }
.full { grid-column: 1 / -1; }
input, textarea, select { font: inherit; font-weight: 400; color: var(--text); padding: 11px 14px; border: 1px solid var(--border); border-radius: 12px; background: #fbfaff; width: 100%; transition: .2s; }
input:focus, textarea:focus, select:focus { outline: none; border-color: var(--violet); box-shadow: 0 0 0 4px rgba(139, 92, 246, .15); }
textarea { min-height: 120px; resize: vertical; }
.grid-form label.check { flex-direction: row; align-items: center; gap: 10px; color: var(--text); }
label.check input { width: auto; }
.file-row { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.file-row input[type=file] { width: auto; flex: 1; min-width: 180px; padding: 8px; }
.thumb { width: 64px; height: 64px; object-fit: cover; border-radius: 10px; border: 1px solid var(--border); }
.file-field.loading { opacity: .6; pointer-events: none; }
.actions { display: flex; justify-content: flex-end; gap: 12px; }

.btn { border: 0; background: var(--grad); color: #fff; padding: 11px 24px; border-radius: 12px; font: inherit; font-weight: 600; cursor: pointer; transition: .2s; }
.btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255, 79, 216, .3); }
.btn:disabled { opacity: .6; transform: none; }
.btn.ghost { background: transparent; color: var(--text); border: 1px solid var(--border); }
.btn.ghost:hover { box-shadow: none; }
.link-btn { background: none; border: 0; color: var(--violet); font: inherit; font-size: .88rem; font-weight: 600; cursor: pointer; padding: 4px 6px; text-decoration: none; }
.link-btn.danger { color: var(--danger); }

.toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; gap: 12px; flex-wrap: wrap; }
.table-wrap { padding: 0; overflow-x: auto; }
table { width: 100%; border-collapse: collapse; font-size: .92rem; }
th, td { padding: 14px 18px; text-align: left; border-bottom: 1px solid var(--border); }
th { color: var(--muted); font-weight: 600; font-size: .78rem; text-transform: uppercase; letter-spacing: .04em; background: #faf9ff; }
tr:last-child td { border-bottom: 0; }
td { max-width: 320px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.row-actions { display: flex; gap: 6px; justify-content: flex-end; flex-wrap: wrap; }
.row-actions.start { justify-content: flex-start; }

.msg { margin-bottom: 16px; border-left: 4px solid transparent; }
.msg.unread { border-left-color: var(--pink); }
.msg header { display: flex; justify-content: space-between; gap: 10px; flex-wrap: wrap; margin-bottom: 10px; }
.msg header a { color: var(--violet); margin-left: 10px; font-size: .9rem; }
.msg time { color: var(--muted); font-size: .82rem; }
.msg h4 { margin-bottom: 6px; }
.msg p { white-space: pre-line; color: #3b3660; margin-bottom: 12px; }

.modal { position: fixed; inset: 0; background: rgba(22, 17, 47, .55); backdrop-filter: blur(4px); display: none; align-items: flex-start; justify-content: center; padding: 40px 16px; overflow-y: auto; z-index: 50; }
.modal.open { display: flex; }
.modal-box { background: var(--card); border-radius: 20px; padding: 28px; width: 100%; max-width: 760px; }
.modal-box h2 { margin-bottom: 20px; }

.toast { position: fixed; bottom: 24px; right: 24px; padding: 14px 22px; border-radius: 12px; color: #fff; background: #16a34a; font-weight: 600; transform: translateY(120px); opacity: 0; transition: .3s; z-index: 80; }
.toast.show { transform: none; opacity: 1; }
.toast.err { background: var(--danger); }

.login-page { align-items: center; justify-content: center; background: var(--side); padding: 20px; }
.login-box { background: var(--card); padding: 40px 34px; border-radius: 24px; width: 100%; max-width: 400px; display: flex; flex-direction: column; gap: 16px; box-shadow: 0 30px 80px rgba(0, 0, 0, .4); }
.login-box h1 { font-size: 1.7rem; background: var(--grad); -webkit-background-clip: text; background-clip: text; color: transparent; }
.login-box label { display: flex; flex-direction: column; gap: 6px; font-size: .88rem; font-weight: 600; color: var(--muted); }

@media (max-width: 900px) {
  .sidebar { transform: translateX(-100%); }
  .sidebar.open { transform: none; }
  .main { margin-left: 0; padding: 20px 16px; }
  .menu-btn { display: block; }
  .grid-form { grid-template-columns: 1fr; }
}
__FIN__

echo "✅ Fichiers écrits."

# ---------------------------------------------------------------- installation
if [ ! -f .env ]; then
  echo "❌ Fichier .env introuvable. Crée-le d'abord (voir les instructions)."
  exit 1
fi

echo "📦 Installation des dépendances..."
npm install

echo "🗄️  Réinitialisation et import de la base (mot de passe sudo demandé)..."
sudo mysql -e "DROP DATABASE IF EXISTS portfolio;"
sudo mysql < database/schema.sql
sudo mysql < database/github-projects.sql

echo ""
read -rp "👤 Identifiant administrateur : " ADMIN_USER
read -rsp "🔑 Mot de passe administrateur (8 caractères min.) : " ADMIN_PASS
echo ""
node scripts/create-admin.js "$ADMIN_USER" "$ADMIN_PASS"

echo ""
echo "🎉 Terminé ! Lance le site avec :  npm run dev"
echo "   Site  : http://localhost:3000"
echo "   Admin : http://localhost:3000/admin"
