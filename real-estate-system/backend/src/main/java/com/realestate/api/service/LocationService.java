package com.realestate.api.service;

import com.realestate.api.dto.CreateLocationRequest;
import com.realestate.api.dto.LocationDTO;
import com.realestate.api.entity.Bien;
import com.realestate.api.entity.Location;
import com.realestate.api.repository.BienRepository;
import com.realestate.api.repository.LocationRepository;
import com.realestate.api.security.SecurityUtils;
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
    private final SecurityUtils securityUtils;

    @Transactional(readOnly = true)
    public List<LocationDTO> findAll() {
        Long agenceId = securityUtils.getCurrentAgenceId();
        List<Location> locations = agenceId != null
                ? locationRepository.findByBienAgenceId(agenceId)
                : locationRepository.findAll();
        return locations.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public LocationDTO findById(Long id) {
        Location loc = locationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Location not found with id: " + id));
        verifyAgencyAccess(loc);
        return convertToDTO(loc);
    }

    public LocationDTO create(CreateLocationRequest request) {
        Bien bien = bienRepository.findById(request.getBienId())
                .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + request.getBienId()));

        verifyBienAgencyAccess(bien);

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

    public LocationDTO update(Long id, CreateLocationRequest request) {
        Location loc = locationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Location not found with id: " + id));
        verifyAgencyAccess(loc);

        if (request.getCaution() != null) loc.setCaution(request.getCaution());
        if (request.getMensualite() != null) loc.setMensualite(request.getMensualite());
        if (request.getDateDispo() != null) loc.setDateDispo(request.getDateDispo());
        if (request.getDureeMois() != null) loc.setDureeMois(request.getDureeMois());

        Location saved = locationRepository.save(loc);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        Location loc = locationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Location not found with id: " + id));
        verifyAgencyAccess(loc);
        Bien bien = loc.getBien();
        if (bien != null) {
            bien.setLocation(null);
        }
        locationRepository.deleteById(id);
    }

    private void verifyAgencyAccess(Location loc) {
        if (loc.getBien() != null) {
            verifyBienAgencyAccess(loc.getBien());
        }
    }

    private void verifyBienAgencyAccess(Bien bien) {
        Long agenceId = securityUtils.getCurrentAgenceId();
        if (agenceId != null && bien.getAgence() != null
                && !bien.getAgence().getId().equals(agenceId)) {
            throw new SecurityException("Access denied: this property belongs to another agency");
        }
    }

    private LocationDTO convertToDTO(Location loc) {
        LocationDTO dto = new LocationDTO();
        dto.setId(loc.getId());
        dto.setCaution(loc.getCaution());
        dto.setDateDispo(loc.getDateDispo());
        dto.setMensualite(loc.getMensualite());
        dto.setDureeMois(loc.getDureeMois());
        if (loc.getBien() != null) {
            dto.setBienId(loc.getBien().getId());
            dto.setBienType(loc.getBien().getType());
            dto.setBienRue(loc.getBien().getRue());
            dto.setBienVille(loc.getBien().getVille());
        }
        return dto;
    }
}
