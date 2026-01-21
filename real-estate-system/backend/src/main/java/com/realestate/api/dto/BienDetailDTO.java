package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class BienDetailDTO extends BienDTO {
    private List<PhotoDTO> photos;
    private List<CaracteristiqueValueDTO> caracteristiques;
    private List<LieuProximiteDTO> lieux;
    private List<ProprietaireDTO> proprietaires;
    private LocationDTO location;
    private AchatDTO achat;
}
