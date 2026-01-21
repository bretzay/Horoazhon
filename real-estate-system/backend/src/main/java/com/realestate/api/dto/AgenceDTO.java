package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AgenceDTO {
    private Long id;
    private String siret;
    private String nom;
    private String numeroTva;
    private String rue;
    private String ville;
    private String codePostal;
    private String telephone;
    private String email;
}
