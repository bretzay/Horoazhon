package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ContratDTO {
    private Long id;
    private LocalDateTime dateCreation;
    private LocalDateTime dateModification;
    private String statut;
    private String type; // LOCATION or ACHAT
    private BienDTO bien;
    private boolean hasSignedDocument;
    private List<CosignerDTO> cosigners;
}
