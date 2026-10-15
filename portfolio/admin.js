const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const fs = require('fs');
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

/* ---------- Upload (images / CV PDF) ----------
   - En ligne : envoi vers Cloudinary si CLOUDINARY_URL est défini
   - En local : enregistrement dans le dossier uploads/ */
const ALLOWED_EXT = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.pdf'];
const UPLOAD_DIR = path.join(__dirname, '..', 'uploads');
const useCloudinary = Boolean(process.env.CLOUDINARY_URL);
const cloudinary = useCloudinary ? require('cloudinary').v2 : null;

const upload = multer({
  storage: useCloudinary
    ? multer.memoryStorage()
    : multer.diskStorage({
      destination: (req, file, cb) => fs.mkdir(UPLOAD_DIR, { recursive: true }, (err) => cb(err, UPLOAD_DIR)),
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

function sendToCloudinary(file) {
  const ext = path.extname(file.originalname).toLowerCase();
  const isPdf = ext === '.pdf';
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: 'portfolio',
        resource_type: isPdf ? 'raw' : 'image',
        public_id: `${Date.now()}-${crypto.randomBytes(6).toString('hex')}${isPdf ? '.pdf' : ''}`,
      },
      (err, result) => (err ? reject(err) : resolve(result.secure_url))
    );
    stream.end(file.buffer);
  });
}

router.post('/upload', upload.single('file'), wrap(async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Aucun fichier reçu' });
  const url = useCloudinary ? await sendToCloudinary(req.file) : `/uploads/${req.file.filename}`;
  res.json({ url });
}));

/* ---------- Messages ---------- */
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
