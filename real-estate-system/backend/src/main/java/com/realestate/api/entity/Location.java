package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Location")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Location {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal caution; // Security deposit

    @Column(nullable = false)
    private LocalDate dateDispo; // Available from

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal mensualite; // Monthly rent

    @Column
    private Integer dureeMois; // Duration in months

    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bien_id", nullable = false, unique = true)
    private Bien bien;

    @OneToMany(mappedBy = "location")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Contrat> contrats = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();
    }
}
