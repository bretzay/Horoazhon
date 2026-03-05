package com.realestate.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ActivateAccountRequest {
    @NotBlank(message = "Le token d'activation est requis")
    private String token;

    @NotBlank(message = "Le mot de passe est requis")
    @Size(min = 6, max = 128, message = "Le mot de passe doit contenir entre 6 et 128 caracteres")
    private String password;
}
