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
