package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

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
    private BigDecimal prix;

    @Column(nullable = false)
    private LocalDate dateDispo;

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bien_id", nullable = false, unique = true)
    private Bien bien;

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }
}
