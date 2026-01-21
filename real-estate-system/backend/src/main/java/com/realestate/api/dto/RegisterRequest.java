package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {
    private String login;
    private String email;
    private String password;
    private String niveauAcces = "USER";

    // Optional person info
    private String nom;
    private String prenom;
    private LocalDate dateNais;
}
