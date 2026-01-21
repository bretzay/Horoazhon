package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PersonneDTO {
    private Long id;
    private String rue;
    private String ville;
    private String codePostal;
    private String nom;
    private String prenom;
    private LocalDate dateNais;
    private BigDecimal avoirs;
}
