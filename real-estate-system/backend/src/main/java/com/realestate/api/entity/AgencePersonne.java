package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "AgencePersonne")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AgencePersonne {

    @EmbeddedId
    private AgencePersonneId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("agenceId")
    @JoinColumn(name = "agence_id")
    private Agence agence;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("personneId")
    @JoinColumn(name = "personne_id")
    private Personne personne;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateAjout;

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AgencePersonneId implements Serializable {
        @Column(name = "agence_id")
        private Long agenceId;

        @Column(name = "personne_id")
        private Long personneId;
    }
}
