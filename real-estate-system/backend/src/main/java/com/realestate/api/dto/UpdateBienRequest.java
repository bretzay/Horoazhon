package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateBienRequest {
    private String rue;
    private String ville;
    private String codePostal;
    private Integer ecoScore;
    private Integer superficie;
    private String description;
    private String type;
}
