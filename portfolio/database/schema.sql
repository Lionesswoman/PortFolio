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
