package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateContratRequest {
    private Long locationId; // Either this...
    private Long achatId;     // ...or this (exclusive)
    private List<CosignerRequest> cosigners; // Must have at least 2
}
