package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Bien (Property) Entity
 * Represents a real estate property that can be for sale, rent, or both
 */
@Entity
@Table(name = "Bien")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Bien {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String rue;

    @Column(nullable = false, length = 100)
    private String ville;

    @Column(nullable = false, length = 10)
    private String codePostal;

    @Column
    private Integer ecoScore;

    @Column
    private Integer superficie; // Total surface area in m²

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(length = 50)
    private String type; // MAISON, APPARTEMENT, TERRAIN, STUDIO

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column
    private LocalDateTime dateModification;

    // Relationships

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agence_id")
    private Agence agence;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "compte_createur_id")
    private Compte createdBy;

    @OneToMany(mappedBy = "bien", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Photo> photos = new ArrayList<>();

    @OneToMany(mappedBy = "bien", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Contenir> caracteristiques = new ArrayList<>();

    @OneToMany(mappedBy = "bien", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Deplacer> lieux = new ArrayList<>();

    @OneToMany(mappedBy = "bien", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Posseder> proprietaires = new ArrayList<>();

    @OneToOne(mappedBy = "bien", cascade = CascadeType.ALL)
    private Location location;

    @OneToOne(mappedBy = "bien", cascade = CascadeType.ALL)
    private Achat achat;

    // Lifecycle callbacks

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
    }

    // Helper methods

    public void addPhoto(Photo photo) {
        photos.add(photo);
        photo.setBien(this);
    }

    public void removePhoto(Photo photo) {
        photos.remove(photo);
        photo.setBien(null);
    }

    public Photo getPrincipalPhoto() {
        return photos.stream()
                .filter(photo -> photo.getOrdre() == 1)
                .findFirst()
                .orElse(null);
    }

    public boolean isAvailableForSale() {
        return achat != null;
    }

    public boolean isAvailableForRent() {
        return location != null;
    }
}
