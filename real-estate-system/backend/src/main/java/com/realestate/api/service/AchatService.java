package com.realestate.api.service;

import com.realestate.api.dto.AchatDTO;
import com.realestate.api.dto.CreateAchatRequest;
import com.realestate.api.entity.Achat;
import com.realestate.api.entity.Bien;
import com.realestate.api.repository.AchatRepository;
import com.realestate.api.repository.BienRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class AchatService {

    private final AchatRepository achatRepository;
    private final BienRepository bienRepository;

    @Transactional(readOnly = true)
    public List<AchatDTO> findAll() {
        return achatRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public AchatDTO findById(Long id) {
        Achat achat = achatRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Achat not found with id: " + id));
        return convertToDTO(achat);
    }

    public AchatDTO create(CreateAchatRequest request) {
        Bien bien = bienRepository.findById(request.getBienId())
                .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + request.getBienId()));

        if (bien.getAchat() != null) {
            throw new IllegalStateException("Bien " + request.getBienId() + " already has a sale listing");
        }

        Achat achat = new Achat();
        achat.setBien(bien);
        achat.setPrix(request.getPrix());
        achat.setDateDispo(request.getDateDispo());

        Achat saved = achatRepository.save(achat);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!achatRepository.existsById(id)) {
            throw new EntityNotFoundException("Achat not found with id: " + id);
        }
        achatRepository.deleteById(id);
    }

    private AchatDTO convertToDTO(Achat a) {
        AchatDTO dto = new AchatDTO();
        dto.setId(a.getId());
        dto.setPrix(a.getPrix());
        dto.setDateDispo(a.getDateDispo());
        return dto;
    }
}
