package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.*;
import com.realestate.api.repository.AgenceRepository;
import com.realestate.api.repository.BienRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class BienService {

    private final BienRepository bienRepository;
    private final AgenceRepository agenceRepository;

    @Transactional(readOnly = true)
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

    @Transactional(readOnly = true)
    public BienDetailDTO findById(Long id) {
        Bien bien = bienRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + id));
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
        bien.setEcoScore(request.getEcoScore());

        if (request.getAgenceId() != null) {
            Agence agence = agenceRepository.findById(request.getAgenceId())
                .orElseThrow(() -> new EntityNotFoundException("Agence not found with id: " + request.getAgenceId()));
            bien.setAgence(agence);
        }

        Bien saved = bienRepository.save(bien);
        return convertToDTO(saved);
    }

    public BienDTO update(Long id, UpdateBienRequest request) {
        Bien bien = bienRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + id));

        if (request.getRue() != null) bien.setRue(request.getRue());
        if (request.getVille() != null) bien.setVille(request.getVille());
        if (request.getCodePostal() != null) bien.setCodePostal(request.getCodePostal());
        if (request.getType() != null) bien.setType(request.getType());
        if (request.getSuperficie() != null) bien.setSuperficie(request.getSuperficie());
        if (request.getDescription() != null) bien.setDescription(request.getDescription());
        if (request.getEcoScore() != null) bien.setEcoScore(request.getEcoScore());

        Bien saved = bienRepository.save(bien);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!bienRepository.existsById(id)) {
            throw new EntityNotFoundException("Bien not found with id: " + id);
        }
        bienRepository.deleteById(id);
    }

    private BienDTO convertToDTO(Bien bien) {
        BienDTO dto = new BienDTO();
        dto.setId(bien.getId());
        dto.setRue(bien.getRue());
        dto.setVille(bien.getVille());
        dto.setCodePostal(bien.getCodePostal());
        dto.setEcoScore(bien.getEcoScore());
        dto.setType(bien.getType());
        dto.setSuperficie(bien.getSuperficie());
        dto.setDescription(bien.getDescription());
        dto.setDateCreation(bien.getDateCreation());
        dto.setAvailableForSale(bien.isAvailableForSale());
        dto.setAvailableForRent(bien.isAvailableForRent());
        dto.setPhotoCount(bien.getPhotos() != null ? bien.getPhotos().size() : 0);

        if (bien.getAgence() != null) {
            AgenceDTO agenceDTO = new AgenceDTO();
            agenceDTO.setId(bien.getAgence().getId());
            agenceDTO.setNom(bien.getAgence().getNom());
            agenceDTO.setSiret(bien.getAgence().getSiret());
            dto.setAgence(agenceDTO);
        }

        Photo principal = bien.getPrincipalPhoto();
        if (principal != null) {
            dto.setPrincipalPhotoUrl(principal.getChemin());
        }

        if (bien.getAchat() != null) {
            dto.setSalePrice(bien.getAchat().getPrix());
        }
        if (bien.getLocation() != null) {
            dto.setMonthlyRent(bien.getLocation().getMensualite());
        }

        return dto;
    }

    private BienDetailDTO convertToDetailDTO(Bien bien) {
        BienDetailDTO dto = new BienDetailDTO();
        // Copy base fields
        dto.setId(bien.getId());
        dto.setRue(bien.getRue());
        dto.setVille(bien.getVille());
        dto.setCodePostal(bien.getCodePostal());
        dto.setEcoScore(bien.getEcoScore());
        dto.setType(bien.getType());
        dto.setSuperficie(bien.getSuperficie());
        dto.setDescription(bien.getDescription());
        dto.setDateCreation(bien.getDateCreation());
        dto.setAvailableForSale(bien.isAvailableForSale());
        dto.setAvailableForRent(bien.isAvailableForRent());
        dto.setPhotoCount(bien.getPhotos() != null ? bien.getPhotos().size() : 0);

        if (bien.getAgence() != null) {
            AgenceDTO agenceDTO = new AgenceDTO();
            agenceDTO.setId(bien.getAgence().getId());
            agenceDTO.setNom(bien.getAgence().getNom());
            agenceDTO.setSiret(bien.getAgence().getSiret());
            dto.setAgence(agenceDTO);
        }

        if (bien.getAchat() != null) {
            dto.setSalePrice(bien.getAchat().getPrix());
            AchatDTO achatDTO = new AchatDTO();
            achatDTO.setId(bien.getAchat().getId());
            achatDTO.setPrix(bien.getAchat().getPrix());
            achatDTO.setDateDispo(bien.getAchat().getDateDispo());
            dto.setAchat(achatDTO);
        }
        if (bien.getLocation() != null) {
            dto.setMonthlyRent(bien.getLocation().getMensualite());
            LocationDTO locDTO = new LocationDTO();
            locDTO.setId(bien.getLocation().getId());
            locDTO.setCaution(bien.getLocation().getCaution());
            locDTO.setDateDispo(bien.getLocation().getDateDispo());
            locDTO.setMensualite(bien.getLocation().getMensualite());
            locDTO.setDureeMois(bien.getLocation().getDureeMois());
            dto.setLocation(locDTO);
        }

        // Photos
        if (bien.getPhotos() != null) {
            dto.setPhotos(bien.getPhotos().stream().map(p -> {
                PhotoDTO pDTO = new PhotoDTO();
                pDTO.setId(p.getId());
                pDTO.setChemin(p.getChemin());
                pDTO.setOrdre(p.getOrdre());
                pDTO.setUrl(p.getChemin());
                pDTO.setDateCreation(p.getDateCreation());
                return pDTO;
            }).collect(Collectors.toList()));
        }

        // Caracteristiques
        if (bien.getCaracteristiques() != null) {
            dto.setCaracteristiques(bien.getCaracteristiques().stream().map(c -> {
                CaracteristiqueValueDTO cvDTO = new CaracteristiqueValueDTO();
                cvDTO.setCaracteristiqueId(c.getCaracteristique().getId());
                cvDTO.setLib(c.getCaracteristique().getLib());
                cvDTO.setUnite(c.getUnite());
                cvDTO.setValeur(c.getValeur());
                return cvDTO;
            }).collect(Collectors.toList()));
        }

        // Lieux
        if (bien.getLieux() != null) {
            dto.setLieux(bien.getLieux().stream().map(d -> {
                LieuProximiteDTO lpDTO = new LieuProximiteDTO();
                lpDTO.setLieuId(d.getLieu().getId());
                lpDTO.setLib(d.getLieu().getLib());
                lpDTO.setMinutes(d.getMinutes());
                lpDTO.setTypeLocomotion(d.getTypeLocomotion());
                return lpDTO;
            }).collect(Collectors.toList()));
        }

        // Proprietaires
        if (bien.getProprietaires() != null) {
            dto.setProprietaires(bien.getProprietaires().stream().map(p -> {
                ProprietaireDTO pDTO = new ProprietaireDTO();
                pDTO.setPersonneId(p.getPersonne().getId());
                pDTO.setNom(p.getPersonne().getNom());
                pDTO.setPrenom(p.getPersonne().getPrenom());
                pDTO.setDateDebut(p.getDateDebut());
                return pDTO;
            }).collect(Collectors.toList()));
        }

        return dto;
    }
}
