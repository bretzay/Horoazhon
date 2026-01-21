package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Entity
@Table(name = "Deplacer")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Deplacer {
    @EmbeddedId
    private DeplacerId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("bienId")
    @JoinColumn(name = "bien_id")
    private Bien bien;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("lieuId")
    @JoinColumn(name = "lieu_id")
    private Lieux lieu;

    @Column(nullable = false)
    private Integer minutes; // Travel time in minutes

    @Column(length = 50)
    private String typeLocomotion; // VOITURE, TRANSPORT_PUBLIC, VELO, MARCHE

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DeplacerId implements Serializable {
        @Column(name = "bien_id")
        private Long bienId;

        @Column(name = "lieu_id")
        private Long lieuId;
    }
}
