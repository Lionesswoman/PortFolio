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
