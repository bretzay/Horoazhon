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
@Table(name = "Achat")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Achat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal prix; // Sale price

    @Column(nullable = false)
    private LocalDate dateDispo; // Available from

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bien_id", nullable = false, unique = true)
    private Bien bien;

    @OneToMany(mappedBy = "achat")
    private List<Contrat> contrats = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }
}
