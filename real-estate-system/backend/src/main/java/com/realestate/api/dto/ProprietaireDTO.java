package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProprietaireDTO {
    private Long personneId;
    private String nom;
    private String prenom;
    private LocalDateTime dateDebut;
}
