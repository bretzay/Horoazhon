package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreatePersonneRequest {
    private String rue;
    private String ville;
    private String codePostal;
    private String rib;
    private String nom;
    private String prenom;
    private LocalDate dateNais;
}
