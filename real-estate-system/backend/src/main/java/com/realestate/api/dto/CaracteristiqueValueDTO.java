package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CaracteristiqueValueDTO {
    private Long caracteristiqueId;
    private String lib;
    private String unite;
    private String valeur;
}
