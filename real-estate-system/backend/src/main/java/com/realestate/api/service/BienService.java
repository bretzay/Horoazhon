package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.Bien;
import com.realestate.api.repository.BienRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional
public class BienService {

    private final BienRepository bienRepository;

    public Page<BienDTO> findAll(
            String ville,
            String type,
            BigDecimal prixMin,
            BigDecimal prixMax,
            Boolean forSale,
            Boolean forRent,
            Pageable pageable
    ) {
        return bienRepository.findByFilters(
            ville, type, forSale, forRent, prixMin, prixMax, pageable
        ).map(this::convertToDTO);
    }

    public BienDetailDTO findById(Long id) {
        Bien bien = bienRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bien not found"));
        return convertToDetailDTO(bien);
    }

    public BienDTO create(CreateBienRequest request) {
        Bien bien = new Bien();
        bien.setRue(request.getRue());
        bien.setVille(request.getVille());
        bien.setCodePostal(request.getCodePostal());
        bien.setType(request.getType());
        bien.setSuperficie(request.getSuperficie());
        bien.setDescription(request.getDescription());
        // Set other fields...
        
        Bien saved = bienRepository.save(bien);
        return convertToDTO(saved);
    }

    private BienDTO convertToDTO(Bien bien) {
        BienDTO dto = new BienDTO();
        dto.setId(bien.getId());
        dto.setRue(bien.getRue());
        dto.setVille(bien.getVille());
        dto.setCodePostal(bien.getCodePostal());
        dto.setType(bien.getType());
        dto.setSuperficie(bien.getSuperficie());
        dto.setDescription(bien.getDescription());
        dto.setAvailableForSale(bien.isAvailableForSale());
        dto.setAvailableForRent(bien.isAvailableForRent());
        // Map other fields...
        return dto;
    }

    private BienDetailDTO convertToDetailDTO(Bien bien) {
        // Implement full mapping with relationships
        BienDetailDTO dto = new BienDetailDTO();
        // ... mapping logic
        return dto;
    }
}
