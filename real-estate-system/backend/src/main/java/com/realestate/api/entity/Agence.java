package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Agence")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Agence {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 14)
    private String siret;

    @Column(nullable = false)
    private String nom;

    @Column(length = 50)
    private String numeroTva;

    @Column(nullable = false)
    private String rue;

    @Column(nullable = false, length = 100)
    private String ville;

    @Column(nullable = false, length = 10)
    private String codePostal;

    @Column(length = 20)
    private String telephone;

    @Column
    private String email;

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column
    private LocalDateTime dateModification;

    @OneToMany(mappedBy = "agence")
    private List<Bien> biens = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
    }
}
