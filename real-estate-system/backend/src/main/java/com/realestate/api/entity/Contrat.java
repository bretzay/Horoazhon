package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Contrat (Contract) Entity
 * Represents a contract that is EITHER for rental OR for purchase (exclusive)
 * The X constraint in MCD ensures a contract can't be both simultaneously
 */
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

    // Exclusive relationship: EITHER location OR achat (enforced by DB constraint)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id")
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "achat_id")
    private Achat achat;

    @Column(length = 500)
    private String documentSigne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_createur_id")
    private Agent createdBy;

    // Co-signers (minimum 2 required)
    @OneToMany(mappedBy = "contrat", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Cosigner> cosigners = new ArrayList<>();

    // Lifecycle callbacks

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
        validateExclusivity();
        // Minimum signers validated in service layer (cosigners not yet persisted at @PrePersist time)
    }

    @PreUpdate
    protected void onUpdate() {
        dateModification = LocalDateTime.now();
        validateExclusivity();
    }

    // Validation methods

    /**
     * Ensures the exclusivity constraint (X in MCD)
     * A contract must have EITHER location OR achat, not both, not neither
     */
    private void validateExclusivity() {
        if ((location == null && achat == null) || (location != null && achat != null)) {
            throw new IllegalStateException(
                "Un contrat doit être soit une location, soit un achat (pas les deux, pas aucun)"
            );
        }
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
        return location != null;
    }

    public boolean isPurchaseContract() {
        return achat != null;
    }

    public TypeContrat getType() {
        if (isRentalContract()) return TypeContrat.LOCATION;
        if (isPurchaseContract()) return TypeContrat.ACHAT;
        return null;
    }

    // Enums

    public enum StatutContrat {
        EN_COURS,    // In progress
        SIGNE,       // Signed
        ANNULE,      // Cancelled
        TERMINE      // Completed
    }

    public enum TypeContrat {
        LOCATION,    // Rental
        ACHAT        // Purchase
    }
}
