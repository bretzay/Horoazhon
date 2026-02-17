package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Cosigner Entity
 * Represents the relationship between Contrat and Personne
 * A contract must have at least 2 co-signers (2,n cardinality)
 * Each co-signer has a role (typeSignataire): BUYER/SELLER or RENTER/OWNER
 */
@Entity
@Table(name = "Cosigner")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Cosigner {

    @EmbeddedId
    private CosignerId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("contratId")
    @JoinColumn(name = "contrat_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Contrat contrat;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("personneId")
    @JoinColumn(name = "personne_id")
    private Personne personne;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private TypeSignataire typeSignataire;

    @Column(nullable = true)
    private LocalDateTime dateSignature;

    // Constructors

    public Cosigner(Contrat contrat, Personne personne, TypeSignataire typeSignataire) {
        this.contrat = contrat;
        this.personne = personne;
        this.typeSignataire = typeSignataire;
        this.id = new CosignerId(contrat.getId(), personne.getId());
    }

    // Enums

    public enum TypeSignataire {
        BUYER,    // Acheteur (for purchase contracts)
        SELLER,   // Vendeur (for purchase contracts)
        RENTER,   // Locataire (for rental contracts)
        OWNER     // Propriétaire (for rental contracts)
    }

    // Composite Key

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CosignerId implements Serializable {
        @Column(name = "contrat_id")
        private Long contratId;

        @Column(name = "personne_id")
        private Long personneId;
    }
}
