package com.realestate.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ForgotPasswordRequest {
    @NotBlank(message = "L'email est requis")
    @Email(message = "L'email doit etre valide")
    private String email;
}
