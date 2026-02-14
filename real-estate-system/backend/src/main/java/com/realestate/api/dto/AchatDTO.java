package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AchatDTO {
    private Long id;
    private BigDecimal prix;
    private LocalDate dateDispo;
    private Long bienId;
    private String bienType;
    private String bienRue;
    private String bienVille;
}
