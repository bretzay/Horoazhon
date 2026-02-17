package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "Compte")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Compte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(length = 255)
    private String password; // BCrypt hashed, NULL until activated

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private Role role = Role.CLIENT;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agence_id", nullable = true)
    private Agence agence;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "personne_id", nullable = false)
    private Personne personne;

    @Column(name = "token_activation", length = 255)
    private String tokenActivation;

    @Column(name = "token_expiration")
    private LocalDateTime tokenExpiration;

    @Column(nullable = false)
    private Boolean actif = true;

    @CreationTimestamp
    @Column(name = "date_creation", nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    public enum Role {
        CLIENT,
        AGENT,
        ADMIN_AGENCY,
        SUPER_ADMIN
    }

    public boolean isActivated() {
        return password != null;
    }

    public boolean isTokenValid() {
        return tokenActivation != null
                && tokenExpiration != null
                && tokenExpiration.isAfter(LocalDateTime.now());
    }

    // Convenience: name comes from the linked Personne
    public String getNom() {
        return personne != null ? personne.getNom() : null;
    }

    public String getPrenom() {
        return personne != null ? personne.getPrenom() : null;
    }

    public boolean isAgent() {
        return role != Role.CLIENT;
    }

    public boolean isClient() {
        return role == Role.CLIENT;
    }

    public boolean isSuperAdmin() {
        return role == Role.SUPER_ADMIN;
    }
}
