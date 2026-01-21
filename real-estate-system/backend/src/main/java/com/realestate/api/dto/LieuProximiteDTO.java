package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LieuProximiteDTO {
    private Long lieuId;
    private String lib;
    private Integer minutes;
    private String typeLocomotion;
}
