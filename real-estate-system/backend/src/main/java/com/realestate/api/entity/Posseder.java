package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "Posseder")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Posseder {
    @EmbeddedId
    private PossederId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("bienId")
    @JoinColumn(name = "bien_id")
    private Bien bien;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("personneId")
    @JoinColumn(name = "personne_id")
    private Personne personne;

    @Column(nullable = false)
    private LocalDateTime dateDebut;

    @PrePersist
    protected void onCreate() {
        if (dateDebut == null) {
            dateDebut = LocalDateTime.now();
        }
    }

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PossederId implements Serializable {
        @Column(name = "bien_id")
        private Long bienId;

        @Column(name = "personne_id")
        private Long personneId;
    }
}
