package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Utilisateur")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Utilisateur {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String login;

    @Column(nullable = false)
    private String mdp; // BCrypt hashed password

    @Column(nullable = false, unique = true)
    private String email;

    @Column(length = 10)
    private String codePin;

    @Column
    private LocalDateTime derniereCo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NiveauAcces niveauAcces;

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column
    private LocalDateTime dateModification;

    @OneToMany(mappedBy = "utilisateur")
    private List<Ouvrir> personnes = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
    }

    public enum NiveauAcces {
        ADMIN,
        AGENT,
        USER
    }
}
