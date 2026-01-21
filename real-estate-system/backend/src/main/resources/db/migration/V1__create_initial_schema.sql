-- ============================================================
-- Flyway Migration V1: Initial Schema Creation
-- Real Estate Management System - Based on Final MCD
-- ============================================================

-- Table: Lieux (Places of interest)
CREATE TABLE Lieux (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    lib NVARCHAR(255) NOT NULL
);

-- Table: Caracteristiques (Property characteristics)
CREATE TABLE Caracteristiques (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    lib NVARCHAR(100) NOT NULL -- e.g., 'Chambres', 'Salles de bain', 'Cuisine', 'Garage'
);

-- Table: Agence (Real Estate Agency)
CREATE TABLE Agence (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    siret NVARCHAR(14) NOT NULL UNIQUE,
    nom NVARCHAR(255) NOT NULL,
    numeroTva NVARCHAR(50),
    rue NVARCHAR(255) NOT NULL,
    ville NVARCHAR(100) NOT NULL,
    codePostal NVARCHAR(10) NOT NULL,
    telephone NVARCHAR(20),
    email NVARCHAR(255),
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2
);

-- Table: Utilisateur (User/Account)
CREATE TABLE Utilisateur (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    login NVARCHAR(50) NOT NULL UNIQUE,
    mdp NVARCHAR(255) NOT NULL, -- Hashed password (use BCrypt)
    email NVARCHAR(255) NOT NULL UNIQUE,
    codePin NVARCHAR(10),
    derniereCo DATETIME2,
    niveauAcces NVARCHAR(20) NOT NULL, -- 'ADMIN', 'AGENT', 'USER'
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2,
    CONSTRAINT CK_NiveauAcces CHECK (niveauAcces IN ('ADMIN', 'AGENT', 'USER'))
);

-- Table: Personne (Person - can be buyer, seller, renter, owner)
CREATE TABLE Personne (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    rue NVARCHAR(255),
    ville NVARCHAR(100),
    codePostal NVARCHAR(10),
    rib NVARCHAR(34), -- IBAN format
    nom NVARCHAR(100) NOT NULL,
    prenom NVARCHAR(100) NOT NULL,
    dateNais DATE NOT NULL,
    avoirs DECIMAL(15,2), -- Financial assets/balance
    derniereCo DATETIME2,
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2
);

-- Table: Ouvrir (Relation Personne - Utilisateur)
-- A Person can open/have a User account (1,1) -> (0,n)
CREATE TABLE Ouvrir (
    personne_id BIGINT NOT NULL,
    utilisateur_id BIGINT NOT NULL,
    dateOuverture DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (personne_id, utilisateur_id),
    FOREIGN KEY (personne_id) REFERENCES Personne(id) ON DELETE CASCADE,
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id) ON DELETE CASCADE
);

-- Table: Bien (Property)
CREATE TABLE Bien (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    rue NVARCHAR(255) NOT NULL,
    ville NVARCHAR(100) NOT NULL,
    codePostal NVARCHAR(10) NOT NULL,
    ecoScore INT,
    superficie INT, -- Total surface (kept for backward compatibility or computed)
    description NTEXT,
    type NVARCHAR(50), -- 'MAISON', 'APPARTEMENT', 'TERRAIN', 'STUDIO', etc.
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2,
    CONSTRAINT CK_Superficie CHECK (superficie >= 0)
);

-- Table: Photo (Property photos)
CREATE TABLE Photo (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    chemin NVARCHAR(500) NOT NULL, -- File path or URL
    ordre INT NOT NULL DEFAULT 1, -- Display order (1 = principal photo)
    dateCreation DATETIME2 DEFAULT GETDATE()
);

-- Relation: Apparaitre (Bien - Photo) [0,n - 1,1]
-- A Photo appears in exactly one Bien
ALTER TABLE Photo ADD bien_id BIGINT NOT NULL;
ALTER TABLE Photo ADD CONSTRAINT FK_Photo_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
CREATE INDEX IDX_Photo_Bien ON Photo(bien_id);
CREATE INDEX IDX_Photo_Ordre ON Photo(bien_id, ordre);

-- Table: Contenir (Relation Bien - Caracteristiques) [0,n - 0,n]
-- A property contains characteristics with unit and value
CREATE TABLE Contenir (
    bien_id BIGINT NOT NULL,
    caracteristique_id BIGINT NOT NULL,
    unite NVARCHAR(50), -- Unit of measurement (optional)
    valeur NVARCHAR(100) NOT NULL, -- Value/count (e.g., '3' for 3 bedrooms)
    PRIMARY KEY (bien_id, caracteristique_id),
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE,
    FOREIGN KEY (caracteristique_id) REFERENCES Caracteristiques(id) ON DELETE CASCADE
);

-- Table: Deplacer (Relation Bien - Lieux) [0,n - 0,n]
-- Travel time from property to places of interest
CREATE TABLE Deplacer (
    bien_id BIGINT NOT NULL,
    lieu_id BIGINT NOT NULL,
    minutes INT NOT NULL, -- Travel time in minutes
    typeLocomotion NVARCHAR(50), -- 'VOITURE', 'TRANSPORT_PUBLIC', 'VELO', 'MARCHE'
    PRIMARY KEY (bien_id, lieu_id),
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE,
    FOREIGN KEY (lieu_id) REFERENCES Lieux(id) ON DELETE CASCADE,
    CONSTRAINT CK_Minutes CHECK (minutes >= 0)
);

-- Relation: Appartenir (Bien - Agence) [0,n - 0,1]
-- A property can belong to an agency
ALTER TABLE Bien ADD agence_id BIGINT NULL;
ALTER TABLE Bien ADD CONSTRAINT FK_Bien_Agence
    FOREIGN KEY (agence_id) REFERENCES Agence(id) ON DELETE SET NULL;

-- Relation: Posseder (Bien - Personne) [1,n - 0,n]
-- A property is owned by one or more persons
CREATE TABLE Posseder (
    bien_id BIGINT NOT NULL,
    personne_id BIGINT NOT NULL,
    dateDebut DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (bien_id, personne_id),
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE,
    FOREIGN KEY (personne_id) REFERENCES Personne(id) ON DELETE CASCADE
);

-- Table: Location (Rental information)
CREATE TABLE Location (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    caution DECIMAL(15,2) NOT NULL, -- Security deposit
    dateDispo DATE NOT NULL, -- Available from date
    mensualite DECIMAL(15,2) NOT NULL, -- Monthly rent
    dureeMois INT, -- Rental duration in months (optional)
    dateCreation DATETIME2 DEFAULT GETDATE()
);

-- Relation: EtreDisponible (Bien - Location) [0,1 - 1,1]
-- A property can be available for rent
ALTER TABLE Location ADD bien_id BIGINT NOT NULL;
ALTER TABLE Location ADD CONSTRAINT FK_Location_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Location ADD CONSTRAINT UQ_Location_Bien UNIQUE (bien_id);

-- Table: Achat (Purchase information)
CREATE TABLE Achat (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    prix DECIMAL(15,2) NOT NULL, -- Sale price
    dateDispo DATE NOT NULL, -- Available from date
    dateCreation DATETIME2 DEFAULT GETDATE()
);

-- Relation: Offrir (Bien - Achat) [0,1 - 1,1]
-- A property can be offered for sale
ALTER TABLE Achat ADD bien_id BIGINT NOT NULL;
ALTER TABLE Achat ADD CONSTRAINT FK_Achat_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Achat ADD CONSTRAINT UQ_Achat_Bien UNIQUE (bien_id);

-- Table: Contrat (Contract)
CREATE TABLE Contrat (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2,
    statut NVARCHAR(50) DEFAULT 'EN_COURS', -- 'EN_COURS', 'SIGNE', 'ANNULE', 'TERMINE'
    CONSTRAINT CK_Contrat_Statut CHECK (statut IN ('EN_COURS', 'SIGNE', 'ANNULE', 'TERMINE'))
);

-- Relation: Signer (Contrat - Location) [0,1 - 0,1] with Exclusivity (X)
-- A contract signs a rental (exclusive with Conclure)
ALTER TABLE Contrat ADD location_id BIGINT NULL;
ALTER TABLE Contrat ADD CONSTRAINT FK_Contrat_Location
    FOREIGN KEY (location_id) REFERENCES Location(id) ON DELETE SET NULL;

-- Relation: Conclure (Contrat - Achat) [0,1 - 0,1] with Exclusivity (X)
-- A contract concludes a purchase (exclusive with Signer)
ALTER TABLE Contrat ADD achat_id BIGINT NULL;
ALTER TABLE Contrat ADD CONSTRAINT FK_Contrat_Achat
    FOREIGN KEY (achat_id) REFERENCES Achat(id) ON DELETE SET NULL;

-- Constraint: Ensure exclusivity (X) - A contract must have EITHER location OR achat, not both, not neither
ALTER TABLE Contrat ADD CONSTRAINT CK_Contrat_Exclusivity
    CHECK (
        (location_id IS NOT NULL AND achat_id IS NULL) OR
        (location_id IS NULL AND achat_id IS NOT NULL)
    );

-- Table: Cosigner (Relation Contrat - Personne) [2,n - 0,n]
-- At least 2 persons must co-sign a contract
-- typeSignataire defines the role: BUYER/SELLER or RENTER/OWNER
CREATE TABLE Cosigner (
    contrat_id BIGINT NOT NULL,
    personne_id BIGINT NOT NULL,
    typeSignataire NVARCHAR(50) NOT NULL, -- 'BUYER', 'SELLER', 'RENTER', 'OWNER'
    dateSignature DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (contrat_id, personne_id),
    FOREIGN KEY (contrat_id) REFERENCES Contrat(id) ON DELETE CASCADE,
    FOREIGN KEY (personne_id) REFERENCES Personne(id) ON DELETE CASCADE,
    CONSTRAINT CK_TypeSignataire CHECK (typeSignataire IN ('BUYER', 'SELLER', 'RENTER', 'OWNER'))
);

-- Additional indexes for performance
CREATE INDEX IDX_Bien_Ville ON Bien(ville);
CREATE INDEX IDX_Bien_Type ON Bien(type);
CREATE INDEX IDX_Bien_Agence ON Bien(agence_id);
CREATE INDEX IDX_Contrat_Location ON Contrat(location_id);
CREATE INDEX IDX_Contrat_Achat ON Contrat(achat_id);
CREATE INDEX IDX_Cosigner_Personne ON Cosigner(personne_id);
CREATE INDEX IDX_Utilisateur_Email ON Utilisateur(email);
CREATE INDEX IDX_Personne_Nom ON Personne(nom, prenom);

-- ============================================================
-- End of Migration V1
-- ============================================================
