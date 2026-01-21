package com.realestate.api.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "Lieux")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Lieux {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String lib; // Label (e.g., "École", "Métro", "Supermarché")

    @OneToMany(mappedBy = "lieu")
    private List<Deplacer> biens = new ArrayList<>();
}
