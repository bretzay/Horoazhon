package com.realestate.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ChangePasswordRequest {

    @NotBlank(message = "Le mot de passe actuel est requis")
    private String currentPassword;

    @NotBlank(message = "Le nouveau mot de passe est requis")
    @Size(min = 6, max = 128, message = "Le nouveau mot de passe doit contenir entre 6 et 128 caracteres")
    private String newPassword;
}
