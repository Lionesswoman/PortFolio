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
