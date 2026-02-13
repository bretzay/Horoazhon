package com.realestate.api.service;

import com.realestate.api.dto.AgenceDTO;
import com.realestate.api.entity.Agence;
import com.realestate.api.repository.AgenceRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class AgenceService {

    private final AgenceRepository agenceRepository;

    @Transactional(readOnly = true)
    public List<AgenceDTO> findAll() {
        return agenceRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public AgenceDTO findById(Long id) {
        Agence agence = agenceRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Agence not found with id: " + id));
        return convertToDTO(agence);
    }

    public AgenceDTO create(AgenceDTO request) {
        if (agenceRepository.findBySiret(request.getSiret()).isPresent()) {
            throw new IllegalArgumentException("Agence with SIRET " + request.getSiret() + " already exists");
        }
        Agence agence = new Agence();
        agence.setSiret(request.getSiret());
        agence.setNom(request.getNom());
        agence.setNumeroTva(request.getNumeroTva());
        agence.setRue(request.getRue());
        agence.setVille(request.getVille());
        agence.setCodePostal(request.getCodePostal());
        agence.setTelephone(request.getTelephone());
        agence.setEmail(request.getEmail());

        Agence saved = agenceRepository.save(agence);
        return convertToDTO(saved);
    }

    public AgenceDTO update(Long id, AgenceDTO request) {
        Agence agence = agenceRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Agence not found with id: " + id));

        if (request.getNom() != null) agence.setNom(request.getNom());
        if (request.getNumeroTva() != null) agence.setNumeroTva(request.getNumeroTva());
        if (request.getRue() != null) agence.setRue(request.getRue());
        if (request.getVille() != null) agence.setVille(request.getVille());
        if (request.getCodePostal() != null) agence.setCodePostal(request.getCodePostal());
        if (request.getTelephone() != null) agence.setTelephone(request.getTelephone());
        if (request.getEmail() != null) agence.setEmail(request.getEmail());

        Agence saved = agenceRepository.save(agence);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!agenceRepository.existsById(id)) {
            throw new EntityNotFoundException("Agence not found with id: " + id);
        }
        agenceRepository.deleteById(id);
    }

    private AgenceDTO convertToDTO(Agence agence) {
        AgenceDTO dto = new AgenceDTO();
        dto.setId(agence.getId());
        dto.setSiret(agence.getSiret());
        dto.setNom(agence.getNom());
        dto.setNumeroTva(agence.getNumeroTva());
        dto.setRue(agence.getRue());
        dto.setVille(agence.getVille());
        dto.setCodePostal(agence.getCodePostal());
        dto.setTelephone(agence.getTelephone());
        dto.setEmail(agence.getEmail());
        return dto;
    }
}