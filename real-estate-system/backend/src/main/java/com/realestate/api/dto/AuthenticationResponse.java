package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthenticationResponse {

    private String token;
    private String type = "Bearer";
    private String role;
    private String nom;
    private String prenom;
    private Long agenceId;
    private String agenceNom;
    private Long personneId; // nullable — only set for CLIENT accounts
}
