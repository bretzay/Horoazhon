package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.*;
import com.realestate.api.repository.BienRepository;
import com.realestate.api.repository.ContratRepository;
import com.realestate.api.repository.PersonneRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientDashboardService {

    private final PersonneRepository personneRepository;
    private final BienRepository bienRepository;
    private final ContratRepository contratRepository;

    public ClientDashboardDTO getDashboard(Long personneId) {
        Personne personne = personneRepository.findById(personneId)
                .orElseThrow(() -> new EntityNotFoundException("Personne not found: " + personneId));

        List<Contrat> allContracts = contratRepository.findAllByPersonneId(personneId);
        Page<Bien> propertiesPage = bienRepository.findByProprietaireId(personneId, Pageable.unpaged());

        ClientDashboardDTO dashboard = new ClientDashboardDTO();
        dashboard.setPersonneId(personne.getId());
        dashboard.setNom(personne.getNom());
        dashboard.setPrenom(personne.getPrenom());

        // Stats
        dashboard.setTotalProperties((int) propertiesPage.getTotalElements());
        dashboard.setTotalContracts(allContracts.size());
        dashboard.setActiveContracts((int) allContracts.stream()
                .filter(c -> c.getStatut() == Contrat.StatutContrat.EN_COURS || c.getStatut() == Contrat.StatutContrat.SIGNE)
                .count());

        // Revenue calculations: only SIGNE and TERMINE rental contracts where this person is OWNER.
        // EN_COURS = not yet signed = no revenue. ANNULE = cancelled = no revenue.
        // All revenue (active + past) is merged into a single timeline.
        BigDecimal totalRevenue = BigDecimal.ZERO;
        BigDecimal monthlyRevenue = BigDecimal.ZERO;
        Map<String, BigDecimal> revenueByMonth = new TreeMap<>();
        YearMonth now = YearMonth.now();
        DateTimeFormatter monthFmt = DateTimeFormatter.ofPattern("yyyy-MM");

        for (Contrat c : allContracts) {
            if (!c.isRentalContract()) continue;
            if (c.getStatut() != Contrat.StatutContrat.SIGNE && c.getStatut() != Contrat.StatutContrat.TERMINE) continue;

            boolean isOwner = c.getCosigners().stream()
                    .anyMatch(cs -> cs.getPersonne().getId().equals(personneId)
                            && cs.getTypeSignataire() == Cosigner.TypeSignataire.OWNER);
            if (!isOwner) continue;

            BigDecimal mensualite = c.getLocation().getMensualite();
            Integer dureeMois = c.getLocation().getDureeMois();

            // Use the latest cosigner signature date as the contract start date for revenue
            LocalDateTime signatureDate = c.getCosigners().stream()
                    .map(Cosigner::getDateSignature)
                    .filter(d -> d != null)
                    .max(LocalDateTime::compareTo)
                    .orElse(c.getDateCreation());
            YearMonth start = YearMonth.from(signatureDate);

            // Determine the end boundary for revenue:
            // - SIGNE: up to current month (skip future)
            // - TERMINE: up to the termination date (dateModification), not the full original duration
            YearMonth endBoundary;
            if (c.getStatut() == Contrat.StatutContrat.TERMINE) {
                endBoundary = YearMonth.from(c.getDateModification());
            } else {
                endBoundary = now;
            }

            if (dureeMois != null && dureeMois > 0) {
                for (int i = 0; i < dureeMois; i++) {
                    YearMonth month = start.plusMonths(i);
                    if (month.isAfter(endBoundary)) break;
                    String key = month.format(monthFmt);
                    revenueByMonth.merge(key, mensualite, BigDecimal::add);
                }

                // Current month revenue (contract is SIGNE and active right now)
                YearMonth contractEnd = start.plusMonths(dureeMois);
                if (c.getStatut() == Contrat.StatutContrat.SIGNE
                        && !now.isBefore(start) && now.isBefore(contractEnd)) {
                    monthlyRevenue = monthlyRevenue.add(mensualite);
                }
            } else if (dureeMois == null) {
                // Indefinite contract: generate revenue from start to endBoundary
                YearMonth month = start;
                while (!month.isAfter(endBoundary)) {
                    String key = month.format(monthFmt);
                    revenueByMonth.merge(key, mensualite, BigDecimal::add);
                    month = month.plusMonths(1);
                }

                if (c.getStatut() == Contrat.StatutContrat.SIGNE && !now.isBefore(start)) {
                    monthlyRevenue = monthlyRevenue.add(mensualite);
                }
            }
        }

        for (BigDecimal v : revenueByMonth.values()) totalRevenue = totalRevenue.add(v);

        dashboard.setTotalRevenue(totalRevenue);
        dashboard.setMonthlyRevenue(monthlyRevenue);
        dashboard.setRevenueByMonth(revenueByMonth);

        // Recent contracts (last 5)
        List<ContratDTO> recentContracts = allContracts.stream()
                .sorted(Comparator.comparing(Contrat::getDateCreation).reversed())
                .limit(5)
                .map(this::convertContratToDTO)
                .collect(Collectors.toList());
        dashboard.setRecentContracts(recentContracts);

        // Properties
        List<BienDTO> properties = propertiesPage.getContent().stream()
                .map(this::convertBienToDTO)
                .collect(Collectors.toList());
        dashboard.setProperties(properties);

        return dashboard;
    }

    public Page<ContratDTO> getClientContracts(Long personneId, Pageable pageable) {
        return contratRepository.findByPersonneId(personneId, pageable)
                .map(this::convertContratToDTO);
    }

    public Page<BienDTO> getClientProperties(Long personneId, Pageable pageable) {
        return bienRepository.findByProprietaireId(personneId, pageable)
                .map(this::convertBienToDTO);
    }

    private ContratDTO convertContratToDTO(Contrat c) {
        ContratDTO dto = new ContratDTO();
        dto.setId(c.getId());
        dto.setDateCreation(c.getDateCreation());
        dto.setDateModification(c.getDateModification());
        dto.setStatut(c.getStatut().name());
        dto.setType(c.getType() != null ? c.getType().name() : null);
        dto.setHasSignedDocument(c.getDocumentSigne() != null && !c.getDocumentSigne().isBlank());

        Bien bien = null;
        if (c.getLocation() != null) bien = c.getLocation().getBien();
        else if (c.getAchat() != null) bien = c.getAchat().getBien();

        if (bien != null) {
            BienDTO bienDTO = new BienDTO();
            bienDTO.setId(bien.getId());
            bienDTO.setRue(bien.getRue());
            bienDTO.setVille(bien.getVille());
            bienDTO.setCodePostal(bien.getCodePostal());
            bienDTO.setType(bien.getType());
            bienDTO.setSuperficie(bien.getSuperficie());
            if (bien.getLocation() != null) {
                bienDTO.setAvailableForRent(true);
                bienDTO.setMonthlyRent(bien.getLocation().getMensualite());
            }
            if (bien.getAchat() != null) {
                bienDTO.setAvailableForSale(true);
                bienDTO.setSalePrice(bien.getAchat().getPrix());
            }
            dto.setBien(bienDTO);
        }

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

    private BienDTO convertBienToDTO(Bien b) {
        BienDTO dto = new BienDTO();
        dto.setId(b.getId());
        dto.setRue(b.getRue());
        dto.setVille(b.getVille());
        dto.setCodePostal(b.getCodePostal());
        dto.setEcoScore(b.getEcoScore());
        dto.setSuperficie(b.getSuperficie());
        dto.setDescription(b.getDescription());
        dto.setType(b.getType());
        dto.setDateCreation(b.getDateCreation());

        if (b.getPhotos() != null && !b.getPhotos().isEmpty()) {
            Photo principal = b.getPrincipalPhoto();
            if (principal != null) dto.setPrincipalPhotoUrl(principal.getChemin());
            dto.setPhotoCount(b.getPhotos().size());
        }

        if (b.getAchat() != null) {
            dto.setAvailableForSale(true);
            dto.setSalePrice(b.getAchat().getPrix());
        }
        if (b.getLocation() != null) {
            dto.setAvailableForRent(true);
            dto.setMonthlyRent(b.getLocation().getMensualite());
        }

        if (b.getAgence() != null) {
            AgenceDTO agenceDTO = new AgenceDTO();
            agenceDTO.setId(b.getAgence().getId());
            agenceDTO.setNom(b.getAgence().getNom());
            dto.setAgence(agenceDTO);
        }

        return dto;
    }
}
