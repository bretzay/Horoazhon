package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BienDTO {
    private Long id;
    private String rue;
    private String ville;
    private String codePostal;
    private Integer ecoScore;
    private Integer superficie;
    private String description;
    private String type;
    private LocalDateTime dateCreation;

    // Relationships
    private AgenceDTO agence;
    private String principalPhotoUrl;
    private int photoCount;

    // Availability info
    private boolean availableForSale;
    private boolean availableForRent;
    private BigDecimal salePrice;
    private BigDecimal monthlyRent;
}
