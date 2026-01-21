package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Entity
@Table(name = "Contenir")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Contenir {
    @EmbeddedId
    private ContenirId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("bienId")
    @JoinColumn(name = "bien_id")
    private Bien bien;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("caracteristiqueId")
    @JoinColumn(name = "caracteristique_id")
    private Caracteristiques caracteristique;

    @Column(length = 50)
    private String unite; // Unit of measurement

    @Column(nullable = false, length = 100)
    private String valeur; // Value/count

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ContenirId implements Serializable {
        @Column(name = "bien_id")
        private Long bienId;

        @Column(name = "caracteristique_id")
        private Long caracteristiqueId;
    }
}
