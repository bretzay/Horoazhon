package com.realestate.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PhotoDTO {
    private Long id;
    private String chemin;
    private Integer ordre;
    private String url; // Full URL for frontend
    private LocalDateTime dateCreation;
}
