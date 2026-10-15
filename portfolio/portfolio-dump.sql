-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: portfolio
-- ------------------------------------------------------
-- Server version	8.4.11-0ubuntu0.26.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'pat','$2a$12$RO6FLJBfH4l9G4U/x6sAWOck3vtBz0oH9BceZjULY.xeFHN2eiCza','2026-10-14 17:49:52');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;

--
-- Table structure for table `experiences`
--

DROP TABLE IF EXISTS `experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiences` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` enum('formation','stage','experience','projet') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'formation',
  `title` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `organization` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `period` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiences`
--

/*!40000 ALTER TABLE `experiences` DISABLE KEYS */;
INSERT INTO `experiences` VALUES (1,'formation','Technicien Supérieur — Génie Logiciel','IAI-Cameroun (Institut Africain d’Informatique)','Octobre 2025 - Octobre 2026','diplome de Technicie Superieur',2),(2,'stage','Stage académique — Projet VIPGo','Albatres Ingénierie, Yaoundé','2026','Conception et développement d’une plateforme de réservation de voyages VIP : Spring Boot, Flutter, IA FastAPI, paiement CAMPOST, déploiement Docker/Railway.',3),(4,'projet','Plateforme web JEAF Sports Management','Albatres Engineering — client JEAF (Malabo)','2026','Analyse, conception et réalisation du site public et de l’espace d’administration.',4),(5,'formation','IIngenieur des Travaux Informatiques- Génie Logiciel','IAI-Cameroun (Institut Africain d’Informatique)','en cour 3e année','en cours de formation en vu d\'obtention du diplôme d\'ingénieur des travaux informatiques',1);
/*!40000 ALTER TABLE `experiences` ENABLE KEYS */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;

--
-- Table structure for table `profile`
--

DROP TABLE IF EXISTS `profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profile` (
  `id` tinyint NOT NULL,
  `full_name` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `github` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linkedin` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cv` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profile`
--

/*!40000 ALTER TABLE `profile` DISABLE KEYS */;
INSERT INTO `profile` VALUES (1,'POKAM TALLA PATRICIA','Développeuse Full-Stack · Web & Mobile','En formation en Génie Logiciel (3ᵉ année) à l’Institut Africain d’Informatique – Cameroun, je conçois et développe des applications web et mobiles complètes : de l’analyse et la modélisation UML jusqu’au déploiement.\n\nJ’aime construire des plateformes utiles qui résolvent des problèmes concrets : réservation de transport, digitalisation de la presse, gestion d’accueil, sites d’actualités sportives…','patriciatalla129@gmail.com','699520497','Yaoundé, Cameroun','https://github.com/Lionesswoman','https://www.linkedin.com/public-profile/settings/','/uploads/1792046906889-39c3e064b375.jpg','/uploads/1792047013417-f83432fc6789.pdf');
/*!40000 ALTER TABLE `profile` ENABLE KEYS */;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `context` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `tech` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `demo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `repo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,'VIPGo','Stage académique — Albatres Ingénierie','Plateforme intelligente de gestion de disponibilité, tarification et réservation en ligne de voyages interurbains en véhicules VIP.','Application mobile Flutter connectée à un backend Spring Boot, avec un module d’intelligence artificielle en Python (FastAPI) entraîné sur l’historique des réservations pour la tarification et la disponibilité.\n\nIntégration du paiement réel CAMPOST (webhook), cache Redis, base PostgreSQL, conteneurisation Docker et déploiement sur Railway.\n\nModèle économique : commission par billet, abonnements des compagnies et contrats négociés.','Spring Boot, Java, Flutter, Dart, Python, FastAPI, PostgreSQL, Redis, Docker, Railway','/uploads/1792046845649-92325ebee0e2.jpg',NULL,'https://github.com/Lionesswoman/VIPGo',1,1,'2026-10-14 17:49:31'),(2,'JEAF Sports Management','Projet client — Albatres Engineering','Plateforme web de JEAF SPORTS MANAGEMENT Ltd (Malabo) : site d’actualités et médias sportifs + espace d’administration complet.','Analyse, conception et réalisation en équipe de la plateforme : site public centré sur l’actualité, rubriques médias (catégories de sports, chaînes TV/Radio, direct) et back-office complet.\n\nAPI sécurisée par JWT, migrations Flyway, documentation Swagger, envoi d’e-mails via Brevo.','Spring Boot, Java, React, PostgreSQL, JWT, Flyway, Swagger, Brevo','/uploads/1792046871242-d588919404ea.jpg',NULL,'https://github.com/Lionesswoman/JEAF_MANAGEMENT_LTD',1,2,'2026-10-14 17:49:31'),(5,'Système d’accueil des visiteurs','Projet en cours','Les visiteurs scannent leurs documents officiels, le service concerné est notifié et un ticket numérique est délivré.','Scan des pièces officielles via des dispositifs intelligents, transmission automatique au service concerné et ticket numérique (numéro de passage + service).\n\nGestion des rendez-vous, guichets, notifications et procédures d’évacuation. Comptes pour les employés et l’administrateur, aucun compte requis pour le visiteur.',NULL,NULL,NULL,NULL,0,5,'2026-10-14 17:49:31'),(7,'Matrix Scanner','Projet Personel','Authentification et certification de documents administratifs PDF par QR Code','Application d\'authentification, de certification et de traçabilité de documents administratifs officiels au format PDF (arrêtés municipaux, pièces d\'état civil, documents de formation).\n\nÀ l\'import d\'un PDF depuis l\'interface web, le système sécurise le document original, découpe chaque page en images haute définition pour un affichage mobile fluide et hors ligne, puis génère un QR Code unique.\n\nEn scannant ce QR Code, on accède à une interface mobile de certification présentant la signature de l\'entreprise, le message réglementaire, la note de consigne et l\'ensemble des pages. Au téléchargement, le serveur génère une page de garde officielle (logo de la commune, signature, consignes) fusionnée avec le document d\'origine.','Python, FastAPI, MySQL, SQLAlchemy, ReportLab, pypdf, pdf2image, SQLite, HTML, CSS, JavaScript','/uploads/1792048534462-250826fa9272.jpg',NULL,'https://github.com/Lionesswoman/mini_scanner_app',1,7,'2026-10-14 17:49:31'),(8,'AutomateIt — Site web','Projet GitHub','Site web vitrine AutomateIt.','Site Web Officiel d\'Automateit Engineering. AutomateIT Engineering accompagne les particuliers, les entreprises et les institutions dans leur transformation numérique grâce à des solutions innovantes, performantes et adaptées à leurs besoins.','React 18 ,TypeScript , Vite,  React,  Router',NULL,NULL,'https://github.com/Lionesswoman/automateit-website',0,8,'2026-10-14 17:49:31'),(9,'YouCanSpeak','Projet En cours','Application YouCanSpeak.','Faciliter la communication entre sourds-muets et personnes entendantes',NULL,NULL,NULL,'https://github.com/Lionesswoman/YouCanSpeak',0,9,'2026-10-14 17:49:31'),(10,'Boutique en ligne','Projet GitHub','Application de boutique : catalogue de produits et gestion des achats.',NULL,NULL,NULL,NULL,'https://github.com/Lionesswoman/Boutique',0,10,'2026-10-14 17:49:31'),(12,'Projet Commun','Projet d’équipe','Projet réalisé en équipe.',NULL,NULL,NULL,NULL,'https://github.com/Lionesswoman/projetCommun',0,12,'2026-10-14 17:49:31'),(13,'Todo List','Projet GitHub','Application de gestion de tâches : ajout, modification, suppression et suivi.',NULL,NULL,NULL,NULL,'https://github.com/Lionesswoman/todolist',0,13,'2026-10-14 17:49:31');
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` tinyint unsigned NOT NULL DEFAULT '80',
  `sort_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES (1,'Java / Spring Boot','Backend',80,1),(2,'Node.js / Express','Backend',80,2),(3,'Python / FastAPI','Backend',70,3),(4,'React','Frontend',75,4),(5,'HTML / CSS / JavaScript','Frontend',85,5),(6,'Flutter / Dart','Mobile',75,6),(7,'Machine Learning (prédiction)','IA & Data',60,7),(8,'PostgreSQL','Bases de données',80,8),(9,'MySQL','Bases de données',80,9),(10,'Redis','Bases de données',60,10),(11,'Docker','DevOps & outils',65,11),(12,'Git / GitHub','DevOps & outils',80,12),(13,'UML / Merise / GanttProject','Analyse & conception',80,13);
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-15  9:09:12
