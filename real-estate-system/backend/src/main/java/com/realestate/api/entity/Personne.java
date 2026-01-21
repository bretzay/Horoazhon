package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Personne")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Personne {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String rue;

    @Column(length = 100)
    private String ville;

    @Column(length = 10)
    private String codePostal;

    @Column(length = 34)
    private String rib; // IBAN

    @Column(nullable = false, length = 100)
    private String nom;

    @Column(nullable = false, length = 100)
    private String prenom;

    @Column(nullable = false)
    private LocalDate dateNais;

    @Column(precision = 15, scale = 2)
    private BigDecimal avoirs; // Financial assets

    @Column
    private LocalDateTime derniereCo;

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column
    private LocalDateTime dateModification;

    @OneToMany(mappedBy = "personne")
    private List<Ouvrir> utilisateurs = new ArrayList<>();

    @OneToMany(mappedBy = "personne")
    private List<Posseder> biens = new ArrayList<>();

    @OneToMany(mappedBy = "personne")
    private List<Cosigner> contrats = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
    }
}
