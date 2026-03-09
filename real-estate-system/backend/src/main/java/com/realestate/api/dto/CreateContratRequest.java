package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateContratRequest {
    private Long bienId;
    private String typeContrat; // LOCATION or ACHAT
    private List<CosignerRequest> cosigners; // Must have at least 2
}
