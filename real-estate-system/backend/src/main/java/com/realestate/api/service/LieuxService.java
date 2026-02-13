package com.realestate.api.service;

import com.realestate.api.dto.LieuDTO;
import com.realestate.api.entity.Lieux;
import com.realestate.api.repository.LieuxRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class LieuxService {

    private final LieuxRepository lieuxRepository;

    @Transactional(readOnly = true)
    public List<LieuDTO> findAll() {
        return lieuxRepository.findAllByOrderByLibAsc().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public LieuDTO findById(Long id) {
        Lieux l = lieuxRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Lieu not found with id: " + id));
        return convertToDTO(l);
    }

    public LieuDTO create(LieuDTO request) {
        Lieux l = new Lieux();
        l.setLib(request.getLib());
        Lieux saved = lieuxRepository.save(l);
        return convertToDTO(saved);
    }

    public LieuDTO update(Long id, LieuDTO request) {
        Lieux l = lieuxRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Lieu not found with id: " + id));
        l.setLib(request.getLib());
        Lieux saved = lieuxRepository.save(l);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!lieuxRepository.existsById(id)) {
            throw new EntityNotFoundException("Lieu not found with id: " + id);
        }
        lieuxRepository.deleteById(id);
    }

    private LieuDTO convertToDTO(Lieux l) {
        LieuDTO dto = new LieuDTO();
        dto.setId(l.getId());
        dto.setLib(l.getLib());
        return dto;
    }
}