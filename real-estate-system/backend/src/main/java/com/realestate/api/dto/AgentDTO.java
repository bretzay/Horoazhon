package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AgentDTO {

    private Long id;
    private String email;
    private String nom;
    private String prenom;
    private Long agenceId;
    private String agenceNom;
    private String role;
    private Boolean actif;
    private LocalDateTime dateCreation;
}
