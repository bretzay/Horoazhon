-- ============================================================
-- Flyway Migration V2: Test Data
-- ============================================================

-- ========================================
-- AGENCE 1: Horoazhon France (Paris)
-- ========================================
INSERT INTO Agence (siret, nom, rue, ville, codePostal, telephone, email)
VALUES ('12345678901234', 'Horoazhon France', '10 Rue de la Paix', 'Paris', '75001', '0145678900', 'contact@horoazhon.fr');

-- ========================================
-- AGENCE 2: Immobilier du Sud (Lyon)
-- ========================================
INSERT INTO Agence (siret, nom, rue, ville, codePostal, telephone, email)
VALUES ('98765432109876', 'Immobilier du Sud', '45 Rue de la Republique', 'Lyon', '69002', '0478123456', 'contact@immosud.fr');

-- ========================================
-- PERSONNES (id 1-18)
-- ========================================

-- Personne 1: Admin Horoazhon
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal)
VALUES ('Nicolas', 'Soral', '1980-01-01', '10 Rue de la Paix', 'Paris', '75001');

-- Personne 2: Agent Horoazhon
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal)
VALUES ('Dupont', 'Jean', '1985-06-15', '20 Boulevard Haussmann', 'Paris', '75009');

-- Personne 3: Owner of properties in Agency 1
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Martin', 'Pierre', '1985-03-15', '5 Avenue Victor Hugo', 'Paris', '75016', 'FR7630001007941234567890185');

-- Personne 4: Owner of properties in Agency 1
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Durand', 'Marie', '1990-07-22', '12 Rue du Commerce', 'Lyon', '69002', 'FR7630004000031234567890143');

-- Personne 5: Owner of a property in Agency 1
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Lefevre', 'Sophie', '1978-11-03', '8 Rue de Rivoli', 'Paris', '75004', 'FR7630006000011234567890189');

-- Personne 6: Owner of a property in Agency 1
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Moreau', 'Luc', '1982-04-28', '33 Avenue des Champs-Elysees', 'Paris', '75008', 'FR7610107001011234567890129');

-- Personne 7: Owner of a property in Agency 1 AND Agency 2 (SHARED)
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Bernard', 'Claire', '1975-09-10', '15 Quai Saint-Antoine', 'Lyon', '69002', 'FR7620041010051234567890135');

-- Personne 8: Admin Immobilier du Sud
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal)
VALUES ('Roux', 'Antoine', '1979-02-20', '45 Rue de la Republique', 'Lyon', '69002');

-- Personne 9: Agent Immobilier du Sud
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal)
VALUES ('Petit', 'Isabelle', '1988-08-14', '10 Place Bellecour', 'Lyon', '69002');

-- Personne 10: Owner of properties in Agency 2
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Garcia', 'Thomas', '1983-12-05', '22 Rue Merciere', 'Lyon', '69002', 'FR7630003030001234567890142');

-- Personne 11: Owner of properties in Agency 2
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Fournier', 'Camille', '1991-06-17', '7 Cours de la Liberte', 'Lyon', '69003', 'FR7614508000501234567890127');

-- Personne 12: Owner of properties in Agency 2
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Lambert', 'Nicolas', '1986-03-25', '18 Rue Garibaldi', 'Lyon', '69006', 'FR7630002032531234567890168');

-- Personne 13: Super Admin Horoazhon
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal)
VALUES ('Super', 'Admin', '1975-01-01', '1 Place de la Republique', 'Paris', '75003');

-- Personne 14: Buyer/Renter in Agency 1 area (also CLIENT account)
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Girard', 'Julien', '1992-05-18', '40 Rue de Turbigo', 'Paris', '75003', 'FR7630001007941234567890200');

-- Personne 15: Buyer/Renter in Agency 1 area
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Robin', 'Emilie', '1994-09-23', '17 Rue Oberkampf', 'Paris', '75011', 'FR7630001007941234567890201');

-- Personne 16: Buyer/Renter in Agency 1 area
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Mercier', 'Hugo', '1988-02-14', '9 Rue de Bretagne', 'Paris', '75003', 'FR7630001007941234567890202');

-- Personne 17: Buyer/Renter in Agency 2 area
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Blanc', 'Marine', '1993-11-30', '28 Rue Victor Hugo', 'Lyon', '69002', 'FR7630001007941234567890203');

-- Personne 18: Buyer/Renter in Agency 2 area
INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib)
VALUES ('Faure', 'Alexandre', '1987-07-09', '5 Place des Terreaux', 'Lyon', '69001', 'FR7630001007941234567890204');

-- ========================================
-- COMPTES
-- ========================================

-- Agence 1 accounts
INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)
VALUES ('admin@horoazhon.fr', '$2a$10$4IJZ9dimJ7uzfHCSoksndedrRJxRKuyKq4WTrf5NH876TJwn9inUG', 1, 1, 'ADMIN_AGENCY', 1, GETDATE());
-- Pwd: Admin (case-sensitive: capital A)

INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)
VALUES ('agent@horoazhon.fr', '$2a$10$npN//NaACo6iy7RIjiG1heMtLP5NWqJDABgFsJYcbKi1RFC29p4EO', 1, 2, 'AGENT', 1, GETDATE());
-- Pwd: Agent (case-sensitive: capital A)

-- Client account (Agence 1) — uses Personne 14 (Girard Julien)
INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)
VALUES ('client@horoazhon.fr', '$2a$10$ILDXK8nfwFVJYn/r5Thl7.MiVW6/pCjFHdH65Y27Mgv7jB0zwBOS.', 1, 14, 'CLIENT', 1, GETDATE());
-- Pwd: Client (case-sensitive: capital C)

-- Agence 2 accounts
INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)
VALUES ('admin@immosud.fr', '$2a$10$4IJZ9dimJ7uzfHCSoksndedrRJxRKuyKq4WTrf5NH876TJwn9inUG', 2, 8, 'ADMIN_AGENCY', 1, GETDATE());
-- Pwd: Admin (case-sensitive: capital A)

INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)
VALUES ('agent@immosud.fr', '$2a$10$npN//NaACo6iy7RIjiG1heMtLP5NWqJDABgFsJYcbKi1RFC29p4EO', 2, 9, 'AGENT', 1, GETDATE());
-- Pwd: Agent (case-sensitive: capital A)

-- No Agence SUPER_ADMIN
INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)
VALUES ('superadmin@horoazhon.fr', '$2a$10$4IJZ9dimJ7uzfHCSoksndedrRJxRKuyKq4WTrf5NH876TJwn9inUG', NULL, 13, 'SUPER_ADMIN', 1, GETDATE());
-- Pwd: Admin (case-sensitive: capital A)

-- ========================================
-- REFERENCE DATA
-- ========================================
INSERT INTO Caracteristiques (lib) VALUES ('Chambres');         -- id 1
INSERT INTO Caracteristiques (lib) VALUES ('Salles de bain');   -- id 2
INSERT INTO Caracteristiques (lib) VALUES ('Parking');          -- id 3

INSERT INTO Lieux (lib) VALUES ('Metro');                       -- id 1
INSERT INTO Lieux (lib) VALUES ('Ecole');                       -- id 2
INSERT INTO Lieux (lib) VALUES ('Supermarche');                 -- id 3

-- ============================================================
-- AGENCY 1 PROPERTIES (5 biens) — Agence Horoazhon
-- ============================================================

-- Bien 1: Appartement Haussmannien (for sale) — owned by Martin Pierre (Personne 3)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('15 Boulevard Haussmann', 'Paris', '75009', 7, 95,
        'Magnifique appartement haussmannien avec moulures, parquet et cheminee. Lumineux, au 3eme etage avec ascenseur. Vue degagee sur le boulevard.',
        'APPARTEMENT', 1, 1);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (485000.00, '2026-04-01', 1);
INSERT INTO Posseder (bien_id, personne_id) VALUES (1, 3);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (1, 1, '3', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (1, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (1, 1, 2, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (1, 3, 5, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&h=600&fit=crop', 1, 1, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&h=600&fit=crop', 2, 1, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop', 3, 1, GETDATE());

-- Bien 2: Studio Marais (for rent) — owned by Durand Marie (Personne 4)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('22 Rue des Francs-Bourgeois', 'Paris', '75003', 5, 28,
        'Studio cosy au coeur du Marais. Ideal investissement locatif ou premier logement. Kitchenette equipee, salle d''eau avec douche.',
        'STUDIO', 1, 2);

INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id) VALUES (1600.00, '2026-03-15', 800.00, 12, 2);
INSERT INTO Posseder (bien_id, personne_id) VALUES (2, 4);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (2, 1, '1', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (2, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (2, 1, 3, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (2, 2, 8, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop', 1, 2, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop', 2, 2, GETDATE());

-- Bien 3: Maison Vincennes (for sale) — owned by Lefevre Sophie (Personne 5)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('8 Rue de Montreuil', 'Vincennes', '94300', 8, 140,
        'Belle maison familiale avec jardin arbore de 200m2. 4 chambres, double sejour, cuisine americaine. Garage double. Proche bois de Vincennes.',
        'MAISON', 1, 1);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (780000.00, '2026-06-01', 3);
INSERT INTO Posseder (bien_id, personne_id) VALUES (3, 5);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (3, 1, '4', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (3, 2, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (3, 3, '2', 'places');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (3, 1, 10, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (3, 2, 5, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (3, 3, 7, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop', 1, 3, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&h=600&fit=crop', 2, 3, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&h=600&fit=crop', 3, 3, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600573472550-8090b5e0745e?w=800&h=600&fit=crop', 4, 3, GETDATE());


-- Bien 4: Appartement Bastille (for rent) — owned by Moreau Luc (Personne 6)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('30 Rue de la Roquette', 'Paris', '75011', 6, 62,
        'Bel appartement renove proche Place de la Bastille. 2 chambres, sejour lumineux, cuisine equipee. Calme sur cour, digicodes.',
        'APPARTEMENT', 1, 2);

INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id) VALUES (2800.00, '2026-03-01', 1400.00, 36, 4);
INSERT INTO Posseder (bien_id, personne_id) VALUES (4, 6);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (4, 1, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (4, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (4, 1, 4, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (4, 3, 3, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop', 1, 4, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800&h=600&fit=crop', 2, 4, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=600&fit=crop', 3, 4, GETDATE());

-- Bien 5: Terrain Fontainebleau (for sale) — owned by Bernard Claire (Personne 7 — SHARED with Agency 2)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('Route de Bourgogne', 'Fontainebleau', '77300', 9, 850,
        'Terrain constructible viabilise en bordure de foret. Permis de construire accorde pour maison individuelle. Environnement calme et verdoyant.',
        'TERRAIN', 1, 1);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (195000.00, '2026-05-01', 5);
INSERT INTO Posseder (bien_id, personne_id) VALUES (5, 7);
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&h=600&fit=crop', 1, 5, GETDATE());

-- ============================================================
-- AGENCY 2 PROPERTIES (5 biens) — Immobilier du Sud
-- ============================================================

-- Bien 6: Appartement Presqu'ile (for sale) — owned by Garcia Thomas (Personne 10)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('14 Rue de la Barre', 'Lyon', '69002', 6, 78,
        'Appartement de standing en plein coeur de la Presqu''ile. Parquet ancien, hauts plafonds, balcon filant. Vue sur la Saone.',
        'APPARTEMENT', 2, 4);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (365000.00, '2026-04-15', 6);
INSERT INTO Posseder (bien_id, personne_id) VALUES (6, 10);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (6, 1, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (6, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (6, 1, 5, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (6, 3, 4, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop', 1, 6, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600585153490-76fb20a32601?w=800&h=600&fit=crop', 2, 6, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1615529328331-f8917597711f?w=800&h=600&fit=crop', 3, 6, GETDATE());

-- Bien 7: Studio Part-Dieu (for rent) — owned by Fournier Camille (Personne 11)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('55 Cours Lafayette', 'Lyon', '69006', 7, 25,
        'Studio fonctionnel a deux pas de la gare Part-Dieu. Ideal etudiant ou jeune actif. Meuble et equipe. Cave incluse.',
        'STUDIO', 2, 5);

INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id) VALUES (1100.00, '2026-03-01', 550.00, 12, 7);
INSERT INTO Posseder (bien_id, personne_id) VALUES (7, 11);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (7, 1, '1', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (7, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (7, 1, 3, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (7, 2, 10, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (7, 3, 2, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800&h=600&fit=crop', 1, 7, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800&h=600&fit=crop', 2, 7, GETDATE());

-- Bien 8: Maison Caluire (for sale) — owned by Lambert Nicolas (Personne 12)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('12 Chemin de Crépieux', 'Caluire-et-Cuire', '69300', 8, 160,
        'Maison contemporaine avec piscine et vue sur Lyon. 5 chambres, suite parentale, grand salon cathedrale. Terrain 500m2 clos.',
        'MAISON', 2, 4);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (620000.00, '2026-07-01', 8);
INSERT INTO Posseder (bien_id, personne_id) VALUES (8, 12);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (8, 1, '5', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (8, 2, '3', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (8, 3, '3', 'places');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (8, 2, 8, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (8, 3, 6, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&h=600&fit=crop', 1, 8, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800&h=600&fit=crop', 2, 8, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?w=800&h=600&fit=crop', 3, 8, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800&h=600&fit=crop', 4, 8, GETDATE());

-- Bien 9: Appartement Confluence (for rent) — owned by Garcia Thomas (Personne 10)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('8 Quai Perrache', 'Lyon', '69002', 9, 55,
        'Appartement neuf dans le quartier Confluence. Terrasse avec vue sur le Rhone. Residence securisee avec parking souterrain. Basse consommation.',
        'APPARTEMENT', 2, 5);

INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id) VALUES (2200.00, '2026-04-01', 1100.00, 24, 9);
INSERT INTO Posseder (bien_id, personne_id) VALUES (9, 10);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (9, 1, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (9, 2, '1', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (9, 3, '1', 'places');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (9, 1, 6, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (9, 3, 3, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800&h=600&fit=crop', 1, 9, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600566753376-12c8ab7c5a38?w=800&h=600&fit=crop', 2, 9, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600585154363-67eb9e2e2099?w=800&h=600&fit=crop', 3, 9, GETDATE());

-- Bien 10: Maison Villeurbanne (for sale) — owned by Bernard Claire (Personne 7 — SHARED owner, also owns Bien 5 in Agency 1)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('25 Rue du 4 Aout 1789', 'Villeurbanne', '69100', 7, 110,
        'Maison de ville avec cour interieure. 3 chambres, bureau, cave voutee. Proximite campus universitaire et transports.',
        'MAISON', 2, 4);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (420000.00, '2026-05-15', 10);
INSERT INTO Posseder (bien_id, personne_id) VALUES (10, 7);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (10, 1, '3', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (10, 2, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (10, 3, '1', 'places');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (10, 1, 5, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (10, 2, 4, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (10, 3, 6, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop', 1, 10, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&h=600&fit=crop', 2, 10, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600210491892-03d54c0aaf87?w=800&h=600&fit=crop', 3, 10, GETDATE());

-- ============================================================
-- ADDITIONAL PROPERTIES — AGENCY 1 (Horoazhon France)
-- ============================================================

-- Bien 11: Appartement Montmartre (for rent) — owned by Martin Pierre (Personne 3)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('42 Rue Lepic', 'Paris', '75018', 5, 45,
        'Charmant 2 pieces au pied de la Butte Montmartre. Vue sur les toits de Paris depuis le balcon. Parquet massif, cuisine ouverte amenagee.',
        'APPARTEMENT', 1, 2);

INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id) VALUES (2000.00, '2026-05-01', 1050.00, 12, 11);
INSERT INTO Posseder (bien_id, personne_id) VALUES (11, 3);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (11, 1, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (11, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (11, 1, 6, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (11, 3, 8, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&h=600&fit=crop', 1, 11, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&h=600&fit=crop', 2, 11, GETDATE());

-- Bien 12: Maison Saint-Germain-en-Laye (for sale) — owned by Durand Marie (Personne 4)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('7 Rue de la Salle', 'Saint-Germain-en-Laye', '78100', 9, 185,
        'Maison bourgeoise proche du chateau. 5 chambres, grand jardin paysager de 400m2, dependance amenageable. Cave voutee, double garage. Quartier residentiel calme.',
        'MAISON', 1, 1);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (920000.00, '2026-08-01', 12);
INSERT INTO Posseder (bien_id, personne_id) VALUES (12, 4);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (12, 1, '5', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (12, 2, '3', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (12, 3, '2', 'places');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (12, 2, 5, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (12, 3, 10, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop', 1, 12, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600573472550-8090b5e0745e?w=800&h=600&fit=crop', 2, 12, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop', 3, 12, GETDATE());

-- ============================================================
-- ADDITIONAL PROPERTIES — AGENCY 2 (Immobilier du Sud)
-- ============================================================

-- Bien 13: Studio Croix-Rousse (for rent) — owned by Fournier Camille (Personne 11)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('18 Montee de la Grande Cote', 'Lyon', '69001', 6, 30,
        'Studio lumineux sur les pentes de la Croix-Rousse. Poutres apparentes, cachet ancien. Ideal premier logement. Proche commerces et transports.',
        'STUDIO', 2, 5);

INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id) VALUES (1200.00, '2026-04-15', 620.00, 12, 13);
INSERT INTO Posseder (bien_id, personne_id) VALUES (13, 11);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (13, 1, '1', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (13, 2, '1', 'pieces');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (13, 1, 4, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (13, 2, 7, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (13, 3, 5, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop', 1, 13, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop', 2, 13, GETDATE());

-- Bien 14: Appartement Tete d'Or (for sale) — owned by Lambert Nicolas (Personne 12)
INSERT INTO Bien (rue, ville, codePostal, ecoScore, superficie, description, type, agence_id, compte_createur_id)
VALUES ('3 Boulevard des Belges', 'Lyon', '69006', 8, 120,
        'Grand appartement familial face au Parc de la Tete d''Or. 4 chambres, double sejour traversant, balcon filant. Standing eleve, gardien, parking.',
        'APPARTEMENT', 2, 4);

INSERT INTO Achat (prix, dateDispo, bien_id) VALUES (550000.00, '2026-06-15', 14);
INSERT INTO Posseder (bien_id, personne_id) VALUES (14, 12);
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (14, 1, '4', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (14, 2, '2', 'pieces');
INSERT INTO Contenir (bien_id, caracteristique_id, valeur, unite) VALUES (14, 3, '1', 'places');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (14, 1, 7, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (14, 2, 3, 'A_PIED');
INSERT INTO Deplacer (bien_id, lieu_id, minutes, typeLocomotion) VALUES (14, 3, 5, 'A_PIED');
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop', 1, 14, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1600585153490-76fb20a32601?w=800&h=600&fit=crop', 2, 14, GETDATE());
INSERT INTO Photo (chemin, ordre, bien_id, dateCreation) VALUES ('https://images.unsplash.com/photo-1615529328331-f8917597711f?w=800&h=600&fit=crop', 3, 14, GETDATE());

-- ============================================================
-- DUAL LISTING: Add a Location to Bien 3 (Maison Vincennes)
-- Already has Achat (id 2, prix 780,000). Now also available for rent.
-- This tests a property with BOTH a sale contract and a rent contract.
-- ============================================================
INSERT INTO Location (caution, dateDispo, mensualite, dureeMois, bien_id)
VALUES (4000.00, '2026-04-01', 2200.00, 24, 3);
-- Location id = 5

-- ============================================================
-- CONTRACTS — AGENCY 1 (Horoazhon France)
-- Contracts now reference Bien directly with snapshot fields
-- ============================================================

-- Contrat 1: SALE of Bien 1 (Appart Haussmann) — snapshot from Achat 1
-- Normal EN_COURS. Seller: Martin Pierre (3), Buyer: Girard Julien (14)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 1, 'ACHAT', 485000.00, '2026-04-01', 1);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (1, 3, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (1, 14, 'BUYER', NULL);

-- Contrat 2: RENT of Bien 2 (Studio Marais) — snapshot from Location 1
-- Normal EN_COURS. Owner: Durand Marie (4), Renter: Robin Emilie (15)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_mensualite, snap_caution, snap_duree_mois, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 2, 'LOCATION', 800.00, 1600.00, 12, '2026-03-15', 2);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (2, 4, 'OWNER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (2, 15, 'RENTER', NULL);

-- Contrats 3, 4, 5: THREE competing contracts for SALE of Bien 5 (Terrain Fontainebleau) — snapshot from Achat 3
-- All EN_COURS on the same Bien+ACHAT. Seller: Bernard Claire (7). Three different buyers.
-- Edge case: confirming one should cancel the other two.
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 5, 'ACHAT', 195000.00, '2026-05-01', 1);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (3, 7, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (3, 14, 'BUYER', NULL);

INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 5, 'ACHAT', 195000.00, '2026-05-01', 1);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (4, 7, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (4, 15, 'BUYER', NULL);

INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 5, 'ACHAT', 195000.00, '2026-05-01', 1);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (5, 7, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (5, 16, 'BUYER', NULL);

-- Contrat 6: SALE of Bien 3 (Maison Vincennes) — snapshot from Achat 2
-- Edge case: same property also has a rent contract (Contrat 7).
-- Seller: Lefevre Sophie (5), Buyer: Mercier Hugo (16)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 3, 'ACHAT', 780000.00, '2026-06-01', 2);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (6, 5, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (6, 16, 'BUYER', NULL);

-- Contrat 7: RENT of Bien 3 (Maison Vincennes) — snapshot from Location 5
-- Edge case: same property as Contrat 6 but for rent (independent listing).
-- Owner: Lefevre Sophie (5), Renter: Girard Julien (14)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_mensualite, snap_caution, snap_duree_mois, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 3, 'LOCATION', 2200.00, 4000.00, 24, '2026-04-01', 2);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (7, 5, 'OWNER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (7, 14, 'RENTER', NULL);

-- ============================================================
-- CONTRACTS — AGENCY 2 (Immobilier du Sud)
-- ============================================================

-- Contrat 8: SALE of Bien 6 (Appart Presqu'ile) — snapshot from Achat 4
-- Normal EN_COURS. Seller: Garcia Thomas (10), Buyer: Blanc Marine (17)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 6, 'ACHAT', 365000.00, '2026-04-15', 4);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (8, 10, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (8, 17, 'BUYER', NULL);

-- Contrat 9: RENT of Bien 7 (Studio Part-Dieu) — snapshot from Location 3
-- Normal EN_COURS. Owner: Fournier Camille (11), Renter: Faure Alexandre (18)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_mensualite, snap_caution, snap_duree_mois, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 7, 'LOCATION', 550.00, 1100.00, 12, '2026-03-01', 5);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (9, 11, 'OWNER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (9, 18, 'RENTER', NULL);

-- Contrat 10: SALE of Bien 10 (Maison Villeurbanne) — snapshot from Achat 6
-- Normal EN_COURS. Seller: Bernard Claire (7), Buyer: Faure Alexandre (18)
INSERT INTO Contrat (statut, bien_id, type_contrat, snap_prix, snap_date_dispo, compte_createur_id)
VALUES ('EN_COURS', 10, 'ACHAT', 420000.00, '2026-05-15', 4);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (10, 7, 'SELLER', NULL);
INSERT INTO Cosigner (contrat_id, personne_id, typeSignataire, dateSignature) VALUES (10, 18, 'BUYER', NULL);

-- ============================================================
-- VERIFY DATA
-- ============================================================
-- SELECT c.id, c.email, p.nom, p.prenom, c.role, c.actif FROM Compte c JOIN Personne p ON c.personne_id = p.id;
-- SELECT id, nom, prenom FROM Personne;
-- SELECT id, nom FROM Agence;
-- SELECT b.id, b.type, b.ville, b.superficie, a.nom as agence FROM Bien b JOIN Agence a ON b.agence_id = a.id;
-- SELECT b.id, p.nom, p.prenom FROM Posseder pos JOIN Bien b ON pos.bien_id = b.id JOIN Personne p ON pos.personne_id = p.id;
-- SELECT ct.id, ct.statut, ct.achat_id, ct.location_id, b.rue, a.nom as agence FROM Contrat ct LEFT JOIN Achat ac ON ct.achat_id = ac.id LEFT JOIN Location lo ON ct.location_id = lo.id LEFT JOIN Bien b ON COALESCE(ac.bien_id, lo.bien_id) = b.id LEFT JOIN Agence a ON b.agence_id = a.id;
