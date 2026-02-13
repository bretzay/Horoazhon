package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.*;
import com.realestate.api.repository.AchatRepository;
import com.realestate.api.repository.ContratRepository;
import com.realestate.api.repository.LocationRepository;
import com.realestate.api.repository.PersonneRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ContratService {

    private final ContratRepository contratRepository;
    private final LocationRepository locationRepository;
    private final AchatRepository achatRepository;
    private final PersonneRepository personneRepository;

    @Transactional(readOnly = true)
    public Page<ContratDTO> findAll(Pageable pageable) {
        return contratRepository.findAll(pageable).map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public ContratDetailDTO findById(Long id) {
        Contrat contrat = contratRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));
        return convertToDetailDTO(contrat);
    }

    public ContratDTO create(CreateContratRequest request) {
        if (request.getCosigners() == null || request.getCosigners().size() < 2) {
            throw new IllegalArgumentException("A contract must have at least 2 cosigners");
        }

        if ((request.getLocationId() == null && request.getAchatId() == null) ||
            (request.getLocationId() != null && request.getAchatId() != null)) {
            throw new IllegalArgumentException("A contract must have either a locationId or achatId (not both, not neither)");
        }

        Contrat contrat = new Contrat();

        if (request.getLocationId() != null) {
            Location loc = locationRepository.findById(request.getLocationId())
                    .orElseThrow(() -> new EntityNotFoundException("Location not found with id: " + request.getLocationId()));
            contrat.setLocation(loc);
        }

        if (request.getAchatId() != null) {
            Achat achat = achatRepository.findById(request.getAchatId())
                    .orElseThrow(() -> new EntityNotFoundException("Achat not found with id: " + request.getAchatId()));
            contrat.setAchat(achat);
        }

        contrat.setStatut(Contrat.StatutContrat.EN_COURS);

        // Save contrat first to get ID
        Contrat saved = contratRepository.save(contrat);

        // Add cosigners
        for (CosignerRequest cr : request.getCosigners()) {
            Personne personne = personneRepository.findById(cr.getPersonneId())
                    .orElseThrow(() -> new EntityNotFoundException("Personne not found with id: " + cr.getPersonneId()));

            Cosigner cosigner = new Cosigner();
            cosigner.setId(new Cosigner.CosignerId(saved.getId(), personne.getId()));
            cosigner.setContrat(saved);
            cosigner.setPersonne(personne);
            cosigner.setTypeSignataire(Cosigner.TypeSignataire.valueOf(cr.getTypeSignataire()));
            saved.getCosigners().add(cosigner);
        }

        saved = contratRepository.save(saved);
        return convertToDTO(saved);
    }

    public ContratDTO updateStatut(Long id, String statut) {
        Contrat contrat = contratRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));
        contrat.setStatut(Contrat.StatutContrat.valueOf(statut));
        Contrat saved = contratRepository.save(contrat);
        return convertToDTO(saved);
    }

    private ContratDTO convertToDTO(Contrat c) {
        ContratDTO dto = new ContratDTO();
        dto.setId(c.getId());
        dto.setDateCreation(c.getDateCreation());
        dto.setDateModification(c.getDateModification());
        dto.setStatut(c.getStatut().name());
        dto.setType(c.getType() != null ? c.getType().name() : null);

        // Get the associated bien
        Bien bien = null;
        if (c.getLocation() != null) {
            bien = c.getLocation().getBien();
        } else if (c.getAchat() != null) {
            bien = c.getAchat().getBien();
        }

        if (bien != null) {
            BienDTO bienDTO = new BienDTO();
            bienDTO.setId(bien.getId());
            bienDTO.setRue(bien.getRue());
            bienDTO.setVille(bien.getVille());
            bienDTO.setCodePostal(bien.getCodePostal());
            bienDTO.setType(bien.getType());
            dto.setBien(bienDTO);
        }

        // Cosigners
        if (c.getCosigners() != null) {
            dto.setCosigners(c.getCosigners().stream().map(cs -> {
                CosignerDTO csDTO = new CosignerDTO();
                csDTO.setPersonneId(cs.getPersonne().getId());
                csDTO.setNom(cs.getPersonne().getNom());
                csDTO.setPrenom(cs.getPersonne().getPrenom());
                csDTO.setTypeSignataire(cs.getTypeSignataire().name());
                csDTO.setDateSignature(cs.getDateSignature());
                return csDTO;
            }).collect(Collectors.toList()));
        }

        return dto;
    }

    private ContratDetailDTO convertToDetailDTO(Contrat c) {
        ContratDetailDTO dto = new ContratDetailDTO();
        // Copy base fields
        ContratDTO base = convertToDTO(c);
        dto.setId(base.getId());
        dto.setDateCreation(base.getDateCreation());
        dto.setDateModification(base.getDateModification());
        dto.setStatut(base.getStatut());
        dto.setType(base.getType());
        dto.setBien(base.getBien());
        dto.setCosigners(base.getCosigners());

        if (c.getLocation() != null) {
            LocationDTO locDTO = new LocationDTO();
            locDTO.setId(c.getLocation().getId());
            locDTO.setCaution(c.getLocation().getCaution());
            locDTO.setDateDispo(c.getLocation().getDateDispo());
            locDTO.setMensualite(c.getLocation().getMensualite());
            locDTO.setDureeMois(c.getLocation().getDureeMois());
            dto.setLocation(locDTO);
        }

        if (c.getAchat() != null) {
            AchatDTO achatDTO = new AchatDTO();
            achatDTO.setId(c.getAchat().getId());
            achatDTO.setPrix(c.getAchat().getPrix());
            achatDTO.setDateDispo(c.getAchat().getDateDispo());
            dto.setAchat(achatDTO);
        }

        return dto;
    }
}
