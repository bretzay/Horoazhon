package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
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

    // Snapshot fields
    private BigDecimal snapMensualite;
    private BigDecimal snapCaution;
    private Integer snapDureeMois;
    private BigDecimal snapPrix;
    private LocalDate snapDateDispo;
}
