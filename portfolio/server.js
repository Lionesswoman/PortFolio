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
