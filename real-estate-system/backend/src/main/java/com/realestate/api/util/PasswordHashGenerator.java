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
        System.out.println("\nSQL to create agent:");
        System.out.println("INSERT INTO Agent (email, password, nom, prenom, agence_id, role, actif, date_creation)");
        System.out.println("VALUES ('admin@agency1.com', '" + hash + "', 'Admin', 'Test', 1, 'ADMIN_AGENCY', 1, GETDATE());");
        System.out.println("========================================");

        // Verify the hash works
        boolean matches = encoder.matches(password, hash);
        System.out.println("\nVerification: " + (matches ? "✓ Hash matches password" : "✗ Hash does NOT match"));
    }
}
