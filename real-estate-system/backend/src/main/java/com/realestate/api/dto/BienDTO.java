package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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
    private List<String> photoUrls = new ArrayList<>();

    // Status
    private boolean actif = true;

    // Availability info
    private boolean availableForSale;
    private boolean availableForRent;
    private BigDecimal salePrice;
    private BigDecimal monthlyRent;
}
