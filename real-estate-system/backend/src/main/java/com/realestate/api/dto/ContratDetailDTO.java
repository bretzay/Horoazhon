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
    private LocationDTO location;
    private AchatDTO achat;
    private int siblingContratCount; // other EN_COURS contracts on the same offer
}
