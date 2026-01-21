package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Caracteristiques")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Caracteristiques {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String lib; // Label (e.g., "Chambres", "Salles de bain")

    @OneToMany(mappedBy = "caracteristique")
    private List<Contenir> biens = new ArrayList<>();
}
