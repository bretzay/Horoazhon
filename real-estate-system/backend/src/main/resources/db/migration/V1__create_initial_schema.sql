-- ============================================================
-- Flyway Migration V1: Initial Schema Creation
-- Real Estate Management System - Based on Final MCD
-- All columns included inline, foreign keys added after all tables
-- ============================================================

-- Table: Lieux (Places of interest)
CREATE TABLE Lieux (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    lib NVARCHAR(255) NOT NULL
);

-- Table: Caracteristiques (Property characteristics)
CREATE TABLE Caracteristiques (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    lib NVARCHAR(100) NOT NULL
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
    mdp NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    codePin NVARCHAR(10),
    derniereCo DATETIME2,
    niveauAcces NVARCHAR(20) NOT NULL,
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2,
    CONSTRAINT CK_NiveauAcces CHECK (niveauAcces IN ('ADMIN', 'AGENT', 'USER'))
);

-- Table: Personne (Person - buyer, seller, renter, owner)
CREATE TABLE Personne (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    rue NVARCHAR(255),
    ville NVARCHAR(100),
    codePostal NVARCHAR(10),
    rib NVARCHAR(34),
    nom NVARCHAR(100) NOT NULL,
    prenom NVARCHAR(100) NOT NULL,
    dateNais DATE NOT NULL,
    avoirs DECIMAL(15,2),
    derniereCo DATETIME2,
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2
);

-- Table: Ouvrir (Relation Personne - Utilisateur)
CREATE TABLE Ouvrir (
    personne_id BIGINT NOT NULL,
    utilisateur_id BIGINT NOT NULL,
    dateOuverture DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (personne_id, utilisateur_id)
);

-- Table: Bien (Property) - includes agence_id
CREATE TABLE Bien (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    rue NVARCHAR(255) NOT NULL,
    ville NVARCHAR(100) NOT NULL,
    codePostal NVARCHAR(10) NOT NULL,
    ecoScore INT,
    superficie INT,
    description NVARCHAR(MAX),
    type NVARCHAR(50),
    agence_id BIGINT NULL,
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2,
    CONSTRAINT CK_Superficie CHECK (superficie >= 0)
);

-- Table: Photo - includes bien_id
CREATE TABLE Photo (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    chemin NVARCHAR(500) NOT NULL,
    ordre INT NOT NULL DEFAULT 1,
    bien_id BIGINT NOT NULL,
    dateCreation DATETIME2 DEFAULT GETDATE()
);

-- Table: Contenir (Bien - Caracteristiques)
CREATE TABLE Contenir (
    bien_id BIGINT NOT NULL,
    caracteristique_id BIGINT NOT NULL,
    unite NVARCHAR(50),
    valeur NVARCHAR(100) NOT NULL,
    PRIMARY KEY (bien_id, caracteristique_id)
);

-- Table: Deplacer (Bien - Lieux)
CREATE TABLE Deplacer (
    bien_id BIGINT NOT NULL,
    lieu_id BIGINT NOT NULL,
    minutes INT NOT NULL,
    typeLocomotion NVARCHAR(50),
    PRIMARY KEY (bien_id, lieu_id),
    CONSTRAINT CK_Minutes CHECK (minutes >= 0)
);

-- Table: Posseder (Bien - Personne)
CREATE TABLE Posseder (
    bien_id BIGINT NOT NULL,
    personne_id BIGINT NOT NULL,
    dateDebut DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (bien_id, personne_id)
);

-- Table: Location - includes bien_id
CREATE TABLE Location (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    caution DECIMAL(15,2) NOT NULL,
    dateDispo DATE NOT NULL,
    mensualite DECIMAL(15,2) NOT NULL,
    dureeMois INT,
    bien_id BIGINT NOT NULL,
    dateCreation DATETIME2 DEFAULT GETDATE()
);

-- Table: Achat - includes bien_id
CREATE TABLE Achat (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    prix DECIMAL(15,2) NOT NULL,
    dateDispo DATE NOT NULL,
    bien_id BIGINT NOT NULL,
    dateCreation DATETIME2 DEFAULT GETDATE()
);

-- Table: Contrat - includes location_id and achat_id
CREATE TABLE Contrat (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    dateCreation DATETIME2 DEFAULT GETDATE(),
    dateModification DATETIME2,
    statut NVARCHAR(50) DEFAULT 'EN_COURS',
    location_id BIGINT NULL,
    achat_id BIGINT NULL,
    CONSTRAINT CK_Contrat_Statut CHECK (statut IN ('EN_COURS', 'SIGNE', 'ANNULE', 'TERMINE')),
    CONSTRAINT CK_Contrat_Exclusivity CHECK (
        (location_id IS NOT NULL AND achat_id IS NULL) OR
        (location_id IS NULL AND achat_id IS NOT NULL)
    )
);

-- Table: Cosigner (Contrat - Personne)
CREATE TABLE Cosigner (
    contrat_id BIGINT NOT NULL,
    personne_id BIGINT NOT NULL,
    typeSignataire NVARCHAR(50) NOT NULL,
    dateSignature DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (contrat_id, personne_id),
    CONSTRAINT CK_TypeSignataire CHECK (typeSignataire IN ('BUYER', 'SELLER', 'RENTER', 'OWNER'))
);

-- ============================================================
-- FOREIGN KEY CONSTRAINTS (all tables exist at this point)
-- ============================================================

ALTER TABLE Ouvrir ADD CONSTRAINT FK_Ouvrir_Personne
    FOREIGN KEY (personne_id) REFERENCES Personne(id) ON DELETE CASCADE;
ALTER TABLE Ouvrir ADD CONSTRAINT FK_Ouvrir_Utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES Utilisateur(id) ON DELETE CASCADE;

ALTER TABLE Bien ADD CONSTRAINT FK_Bien_Agence
    FOREIGN KEY (agence_id) REFERENCES Agence(id) ON DELETE SET NULL;

ALTER TABLE Photo ADD CONSTRAINT FK_Photo_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;

ALTER TABLE Contenir ADD CONSTRAINT FK_Contenir_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Contenir ADD CONSTRAINT FK_Contenir_Caracteristique
    FOREIGN KEY (caracteristique_id) REFERENCES Caracteristiques(id) ON DELETE CASCADE;

ALTER TABLE Deplacer ADD CONSTRAINT FK_Deplacer_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Deplacer ADD CONSTRAINT FK_Deplacer_Lieu
    FOREIGN KEY (lieu_id) REFERENCES Lieux(id) ON DELETE CASCADE;

ALTER TABLE Posseder ADD CONSTRAINT FK_Posseder_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Posseder ADD CONSTRAINT FK_Posseder_Personne
    FOREIGN KEY (personne_id) REFERENCES Personne(id) ON DELETE CASCADE;

ALTER TABLE Location ADD CONSTRAINT FK_Location_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Location ADD CONSTRAINT UQ_Location_Bien UNIQUE (bien_id);

ALTER TABLE Achat ADD CONSTRAINT FK_Achat_Bien
    FOREIGN KEY (bien_id) REFERENCES Bien(id) ON DELETE CASCADE;
ALTER TABLE Achat ADD CONSTRAINT UQ_Achat_Bien UNIQUE (bien_id);

ALTER TABLE Contrat ADD CONSTRAINT FK_Contrat_Location
    FOREIGN KEY (location_id) REFERENCES Location(id) ON DELETE NO ACTION;
ALTER TABLE Contrat ADD CONSTRAINT FK_Contrat_Achat
    FOREIGN KEY (achat_id) REFERENCES Achat(id) ON DELETE NO ACTION;

ALTER TABLE Cosigner ADD CONSTRAINT FK_Cosigner_Contrat
    FOREIGN KEY (contrat_id) REFERENCES Contrat(id) ON DELETE CASCADE;
ALTER TABLE Cosigner ADD CONSTRAINT FK_Cosigner_Personne
    FOREIGN KEY (personne_id) REFERENCES Personne(id) ON DELETE CASCADE;

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IDX_Photo_Bien ON Photo(bien_id);
CREATE INDEX IDX_Photo_Ordre ON Photo(bien_id, ordre);
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