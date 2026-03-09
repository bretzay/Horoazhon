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
@Table(name = "Contrat")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Contrat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column
    private LocalDateTime dateModification;

    @Enumerated(EnumType.STRING)
    @Column(length = 50, nullable = false)
    private StatutContrat statut = StatutContrat.EN_COURS;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bien_id", nullable = false)
    private Bien bien;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_contrat", length = 50, nullable = false)
    private TypeContrat typeContrat;

    // Snapshot fields — copied from offer at contract creation time
    @Column(name = "snap_mensualite", precision = 15, scale = 2)
    private BigDecimal snapMensualite;

    @Column(name = "snap_caution", precision = 15, scale = 2)
    private BigDecimal snapCaution;

    @Column(name = "snap_duree_mois")
    private Integer snapDureeMois;

    @Column(name = "snap_prix", precision = 15, scale = 2)
    private BigDecimal snapPrix;

    @Column(name = "snap_date_dispo")
    private LocalDate snapDateDispo;

    @Column(length = 500)
    private String documentSigne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "compte_createur_id")
    private Compte createdBy;

    @OneToMany(mappedBy = "contrat", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Cosigner> cosigners = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
    }

    // Helper methods

    public void addCosigner(Cosigner cosigner) {
        cosigners.add(cosigner);
        cosigner.setContrat(this);
    }

    public void removeCosigner(Cosigner cosigner) {
        cosigners.remove(cosigner);
        cosigner.setContrat(null);
    }

    public boolean isRentalContract() {
        return typeContrat == TypeContrat.LOCATION;
    }

    public boolean isPurchaseContract() {
        return typeContrat == TypeContrat.ACHAT;
    }

    public TypeContrat getType() {
        return typeContrat;
    }

    // Enums

    public enum StatutContrat {
        EN_COURS,
        SIGNE,
        ANNULE,
        TERMINE
    }

    public enum TypeContrat {
        LOCATION,
        ACHAT
    }
}
