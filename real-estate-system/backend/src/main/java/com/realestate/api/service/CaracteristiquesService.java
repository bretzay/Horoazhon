package com.realestate.api.service;

import com.realestate.api.dto.CaracteristiqueDTO;
import com.realestate.api.entity.Caracteristiques;
import com.realestate.api.repository.CaracteristiquesRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CaracteristiquesService {

    private final CaracteristiquesRepository caracteristiquesRepository;

    @Transactional(readOnly = true)
    public List<CaracteristiqueDTO> findAll() {
        return caracteristiquesRepository.findAllByOrderByLibAsc().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CaracteristiqueDTO findById(Long id) {
        Caracteristiques c = caracteristiquesRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Caracteristique not found with id: " + id));
        return convertToDTO(c);
    }

    public CaracteristiqueDTO create(CaracteristiqueDTO request) {
        Caracteristiques c = new Caracteristiques();
        c.setLib(request.getLib());
        Caracteristiques saved = caracteristiquesRepository.save(c);
        return convertToDTO(saved);
    }

    public CaracteristiqueDTO update(Long id, CaracteristiqueDTO request) {
        Caracteristiques c = caracteristiquesRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Caracteristique not found with id: " + id));
        c.setLib(request.getLib());
        Caracteristiques saved = caracteristiquesRepository.save(c);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!caracteristiquesRepository.existsById(id)) {
            throw new EntityNotFoundException("Caracteristique not found with id: " + id);
        }
        caracteristiquesRepository.deleteById(id);
    }

    private CaracteristiqueDTO convertToDTO(Caracteristiques c) {
        CaracteristiqueDTO dto = new CaracteristiqueDTO();
        dto.setId(c.getId());
        dto.setLib(c.getLib());
        return dto;
    }
}