package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class ContratDetailDTO extends ContratDTO {
    private int siblingContratCount; // other EN_COURS contracts of same type on same Bien
}
