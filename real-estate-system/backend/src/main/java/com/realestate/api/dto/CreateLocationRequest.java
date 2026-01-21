package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateLocationRequest {
    private Long bienId;
    private BigDecimal caution;
    private LocalDate dateDispo;
    private BigDecimal mensualite;
    private Integer dureeMois;
}
