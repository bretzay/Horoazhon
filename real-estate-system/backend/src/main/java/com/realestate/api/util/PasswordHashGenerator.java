package com.realestate.api.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordHashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "Admin";
        String hash = encoder.encode(password);

        System.out.println("========================================");
        System.out.println("Password: " + password);
        System.out.println("BCrypt Hash: " + hash);
        System.out.println("========================================");

        System.out.println("\n-- ========================================");
        System.out.println("-- TEST DATA: Run after V1 migration");
        System.out.println("-- ========================================\n");

        // Agence
        System.out.println("-- Create test agency");
        System.out.println("INSERT INTO Agence (siret, nom, rue, ville, codePostal, telephone, email)");
        System.out.println("VALUES ('12345678901234', 'Agence Horoazhon', '10 Rue de la Paix', 'Paris', '75001', '0145678900', 'contact@horoazhon.fr');");

        // Personnes (must be created before Comptes since Compte.personne_id is NOT NULL)
        System.out.println("\n-- Create personnes for users and clients");
        System.out.println("INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal) VALUES ('Admin', 'Test', '1980-01-01', '10 Rue de la Paix', 'Paris', '75001');");
        System.out.println("INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal) VALUES ('Dupont', 'Jean', '1985-06-15', '20 Boulevard Haussmann', 'Paris', '75009');");
        System.out.println("INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib) VALUES ('Martin', 'Pierre', '1985-03-15', '5 Avenue Victor Hugo', 'Paris', '75016', 'FR7630001007941234567890185');");
        System.out.println("INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal, rib) VALUES ('Durand', 'Marie', '1990-07-22', '12 Rue du Commerce', 'Lyon', '69002', 'FR7630004000031234567890143');");

        // Admin Compte (linked to Personne id=1)
        System.out.println("\n-- Create admin user (password: Admin) linked to Personne 1");
        System.out.println("INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)");
        System.out.println("VALUES ('admin@horoazhon.fr', '" + hash + "', 1, 1, 'ADMIN_AGENCY', 1, GETDATE());");

        // Agent Compte (linked to Personne id=2)
        String agentHash = encoder.encode("Agent");
        System.out.println("\n-- Create agent user (password: Agent) linked to Personne 2");
        System.out.println("INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)");
        System.out.println("VALUES ('agent@horoazhon.fr', '" + agentHash + "', 1, 2, 'AGENT', 1, GETDATE());");

        // SUPER_ADMIN Compte — no agency (agence_id = NULL)
        // Needs its own Personne first
        System.out.println("\n-- Create personne for super admin");
        System.out.println("INSERT INTO Personne (nom, prenom, dateNais, rue, ville, codePostal) VALUES ('Super', 'Admin', '1975-01-01', '1 Place de la Republique', 'Paris', '75003');");
        String superHash = encoder.encode("SuperAdmin");
        System.out.println("\n-- Create super admin user (password: SuperAdmin) — no agency");
        System.out.println("INSERT INTO Compte (email, password, agence_id, personne_id, role, actif, date_creation)");
        System.out.println("VALUES ('superadmin@horoazhon.fr', '" + superHash + "', NULL, 5, 'SUPER_ADMIN', 1, GETDATE());");

        // Reference data
        System.out.println("\n-- Create reference data");
        System.out.println("INSERT INTO Caracteristiques (lib) VALUES ('Chambres');");
        System.out.println("INSERT INTO Caracteristiques (lib) VALUES ('Salles de bain');");
        System.out.println("INSERT INTO Caracteristiques (lib) VALUES ('Parking');");
        System.out.println("INSERT INTO Lieux (lib) VALUES ('Metro');");
        System.out.println("INSERT INTO Lieux (lib) VALUES ('Ecole');");
        System.out.println("INSERT INTO Lieux (lib) VALUES ('Supermarche');");

        System.out.println("\n-- ========================================");
        System.out.println("-- Verify data");
        System.out.println("-- ========================================");
        System.out.println("-- SELECT c.id, c.email, p.nom, p.prenom, c.role, c.actif FROM Compte c JOIN Personne p ON c.personne_id = p.id;");
        System.out.println("-- SELECT id, nom, prenom FROM Personne;");
        System.out.println("-- SELECT id, nom FROM Agence;");

        // Verify the hash works
        boolean matches = encoder.matches(password, hash);
        System.out.println("\n-- Hash verification: " + (matches ? "OK" : "FAILED"));
    }
}
