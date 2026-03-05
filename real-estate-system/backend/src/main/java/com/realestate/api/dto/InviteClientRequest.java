package com.realestate.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InviteClientRequest {
    @NotNull(message = "L'identifiant de la personne est requis")
    private Long personneId;

    @NotBlank(message = "L'email est requis")
    @Email(message = "L'email doit etre valide")
    private String email;

    private Long agenceId;
}
