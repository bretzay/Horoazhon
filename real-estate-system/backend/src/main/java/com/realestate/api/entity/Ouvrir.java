package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "Ouvrir")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Ouvrir {
    @EmbeddedId
    private OuvrirId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("personneId")
    @JoinColumn(name = "personne_id")
    private Personne personne;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("utilisateurId")
    @JoinColumn(name = "utilisateur_id")
    private Utilisateur utilisateur;

    @Column(nullable = false)
    private LocalDateTime dateOuverture;

    @PrePersist
    protected void onCreate() {
        if (dateOuverture == null) {
            dateOuverture = LocalDateTime.now();
        }
    }

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OuvrirId implements Serializable {
        @Column(name = "personne_id")
        private Long personneId;

        @Column(name = "utilisateur_id")
        private Long utilisateurId;
    }
}
