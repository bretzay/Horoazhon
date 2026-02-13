package com.realestate.api.service;

import com.realestate.api.dto.CreateLocationRequest;
import com.realestate.api.dto.LocationDTO;
import com.realestate.api.entity.Bien;
import com.realestate.api.entity.Location;
import com.realestate.api.repository.BienRepository;
import com.realestate.api.repository.LocationRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class LocationService {

    private final LocationRepository locationRepository;
    private final BienRepository bienRepository;

    @Transactional(readOnly = true)
    public List<LocationDTO> findAll() {
        return locationRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public LocationDTO findById(Long id) {
        Location loc = locationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Location not found with id: " + id));
        return convertToDTO(loc);
    }

    public LocationDTO create(CreateLocationRequest request) {
        Bien bien = bienRepository.findById(request.getBienId())
                .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + request.getBienId()));

        if (bien.getLocation() != null) {
            throw new IllegalStateException("Bien " + request.getBienId() + " already has a rental listing");
        }

        Location loc = new Location();
        loc.setBien(bien);
        loc.setCaution(request.getCaution());
        loc.setDateDispo(request.getDateDispo());
        loc.setMensualite(request.getMensualite());
        loc.setDureeMois(request.getDureeMois());

        Location saved = locationRepository.save(loc);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!locationRepository.existsById(id)) {
            throw new EntityNotFoundException("Location not found with id: " + id);
        }
        locationRepository.deleteById(id);
    }

    private LocationDTO convertToDTO(Location loc) {
        LocationDTO dto = new LocationDTO();
        dto.setId(loc.getId());
        dto.setCaution(loc.getCaution());
        dto.setDateDispo(loc.getDateDispo());
        dto.setMensualite(loc.getMensualite());
        dto.setDureeMois(loc.getDureeMois());
        return dto;
    }
}
