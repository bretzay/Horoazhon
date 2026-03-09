package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.*;
import com.realestate.api.repository.*;
import com.realestate.api.security.SecurityUtils;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class ContratService {

    private final ContratRepository contratRepository;
    private final LocationRepository locationRepository;
    private final AchatRepository achatRepository;
    private final PersonneRepository personneRepository;
    private final PossederRepository possederRepository;
    private final BienRepository bienRepository;
    private final SecurityUtils securityUtils;
    private final ContratPdfService contratPdfService;

    @Value("${file.upload-dir-contrats:./uploads/contrats}")
    private String uploadDir;

    @Transactional(readOnly = true)
    public Page<ContratDTO> findAll(Pageable pageable) {
        Long agenceId = securityUtils.getCurrentAgenceId();
        if (agenceId != null) {
            return contratRepository.findByAgence(agenceId, pageable).map(this::convertToDTO);
        }
        return contratRepository.findAll(pageable).map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public ContratDetailDTO findById(Long id) {
        Contrat contrat = contratRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));
        return convertToDetailDTO(contrat);
    }

    public ContratDTO create(CreateContratRequest request) {
        if (request.getCosigners() == null || request.getCosigners().size() < 2) {
            throw new IllegalArgumentException("A contract must have at least 2 cosigners");
        }

        if (request.getBienId() == null || request.getTypeContrat() == null) {
            throw new IllegalArgumentException("bienId and typeContrat are required");
        }

        Contrat.TypeContrat typeContrat = Contrat.TypeContrat.valueOf(request.getTypeContrat());

        Bien bien = bienRepository.findById(request.getBienId())
                .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + request.getBienId()));

        Contrat contrat = new Contrat();
        contrat.setBien(bien);
        contrat.setTypeContrat(typeContrat);
        contrat.setStatut(Contrat.StatutContrat.EN_COURS);
        contrat.setCreatedBy(securityUtils.getCurrentCompteOrThrow());

        // Snapshot fields from the active offer
        if (typeContrat == Contrat.TypeContrat.LOCATION) {
            Location loc = bien.getLocation();
            if (loc == null) {
                throw new IllegalArgumentException("Bien " + bien.getId() + " has no active rental offer (Location)");
            }
            contrat.setSnapMensualite(loc.getMensualite());
            contrat.setSnapCaution(loc.getCaution());
            contrat.setSnapDureeMois(loc.getDureeMois());
            contrat.setSnapDateDispo(loc.getDateDispo());
        } else {
            Achat achat = bien.getAchat();
            if (achat == null) {
                throw new IllegalArgumentException("Bien " + bien.getId() + " has no active sale offer (Achat)");
            }
            contrat.setSnapPrix(achat.getPrix());
            contrat.setSnapDateDispo(achat.getDateDispo());
        }

        // Add cosigners
        for (CosignerRequest cr : request.getCosigners()) {
            Personne personne = personneRepository.findById(cr.getPersonneId())
                    .orElseThrow(() -> new EntityNotFoundException("Personne not found with id: " + cr.getPersonneId()));

            Cosigner cosigner = new Cosigner();
            cosigner.setContrat(contrat);
            cosigner.setPersonne(personne);
            cosigner.setId(new Cosigner.CosignerId());
            cosigner.setTypeSignataire(Cosigner.TypeSignataire.valueOf(cr.getTypeSignataire()));
            contrat.getCosigners().add(cosigner);
        }

        Contrat saved = contratRepository.saveAndFlush(contrat);
        return convertToDTO(saved);
    }

    public ContratDTO updateStatut(Long id, String statut) {
        Contrat contrat = contratRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));

        Contrat.StatutContrat currentStatut = contrat.getStatut();
        Contrat.StatutContrat newStatut = Contrat.StatutContrat.valueOf(statut);

        if (currentStatut == Contrat.StatutContrat.TERMINE) {
            throw new IllegalArgumentException("Un contrat termine ne peut plus etre modifie.");
        }

        if (currentStatut == Contrat.StatutContrat.SIGNE && newStatut != Contrat.StatutContrat.TERMINE) {
            throw new IllegalArgumentException("Un contrat signe ne peut qu'etre termine.");
        }

        if ((newStatut == Contrat.StatutContrat.SIGNE || newStatut == Contrat.StatutContrat.TERMINE)
                && (contrat.getDocumentSigne() == null || contrat.getDocumentSigne().isBlank())) {
            throw new IllegalArgumentException("Impossible de passer en " + statut + " sans document signe.");
        }

        if (newStatut == Contrat.StatutContrat.EN_COURS
                && (currentStatut == Contrat.StatutContrat.SIGNE || currentStatut == Contrat.StatutContrat.TERMINE)) {
            throw new IllegalArgumentException("Impossible de revenir en EN_COURS depuis " + currentStatut.name() + ".");
        }

        contrat.setStatut(newStatut);
        contratRepository.save(contrat);

        // When a purchase contract is terminated (sale completed), handle ownership transfer
        if (newStatut == Contrat.StatutContrat.TERMINE && contrat.isPurchaseContract()) {
            handlePurchaseCompletion(contrat);
        }

        return convertToDTO(contrat);
    }

    private void handlePurchaseCompletion(Contrat purchaseContrat) {
        Bien bien = purchaseContrat.getBien();
        LocalDateTime now = LocalDateTime.now();

        // Find buyer from cosigners
        Personne buyer = null;
        for (Cosigner cs : purchaseContrat.getCosigners()) {
            if (cs.getTypeSignataire() == Cosigner.TypeSignataire.BUYER) {
                buyer = cs.getPersonne();
                break;
            }
        }

        if (buyer == null) {
            throw new IllegalStateException("Contrat d'achat sans acheteur.");
        }

        // 1. Transfer ownership to the buyer
        possederRepository.deleteByBienId(bien.getId());
        possederRepository.flush();

        Posseder newOwnership = new Posseder();
        newOwnership.setId(new Posseder.PossederId(bien.getId(), buyer.getId()));
        newOwnership.setBien(bien);
        newOwnership.setPersonne(buyer);
        newOwnership.setDateDebut(now);
        possederRepository.save(newOwnership);

        log.info("Ownership of bien #{} transferred to {} {} (personne #{})",
                bien.getId(), buyer.getPrenom(), buyer.getNom(), buyer.getId());

        // 2. Handle active rental contracts on this property
        List<Contrat> rentalContracts = contratRepository.findByBienIdAndTypeContrat(bien.getId(), Contrat.TypeContrat.LOCATION);
        boolean hasActiveRental = false;

        for (Contrat rentalContrat : rentalContracts) {
            if (rentalContrat.getStatut() == Contrat.StatutContrat.SIGNE) {
                hasActiveRental = true;
                rentalContrat.setStatut(Contrat.StatutContrat.TERMINE);
                contratRepository.save(rentalContrat);
                log.info("Rental contrat #{} terminated early due to sale of bien #{}",
                        rentalContrat.getId(), bien.getId());

                Personne renter = null;
                for (Cosigner cs : rentalContrat.getCosigners()) {
                    if (cs.getTypeSignataire() == Cosigner.TypeSignataire.RENTER) {
                        renter = cs.getPersonne();
                        break;
                    }
                }

                if (renter != null && bien.getLocation() != null) {
                    createReconductionContract(rentalContrat, buyer, renter, bien, purchaseContrat);
                }
            } else if (rentalContrat.getStatut() == Contrat.StatutContrat.EN_COURS) {
                rentalContrat.setStatut(Contrat.StatutContrat.ANNULE);
                contratRepository.save(rentalContrat);
                log.info("Rental contrat #{} (EN_COURS) cancelled due to sale of bien #{}",
                        rentalContrat.getId(), bien.getId());
            }
        }

        // Only unlink the rental offer if there was no active rental running
        if (!hasActiveRental && bien.getLocation() != null) {
            bien.setLocation(null);
            bienRepository.save(bien);
            log.info("Rental offer unlinked from bien #{} after sale (no active rental)", bien.getId());
        }

        // 3. Cancel any other EN_COURS purchase contracts on the same bien
        List<Contrat> purchaseContracts = contratRepository.findByBienIdAndTypeContrat(bien.getId(), Contrat.TypeContrat.ACHAT);
        for (Contrat sibling : purchaseContracts) {
            if (!sibling.getId().equals(purchaseContrat.getId())
                    && sibling.getStatut() == Contrat.StatutContrat.EN_COURS) {
                sibling.setStatut(Contrat.StatutContrat.ANNULE);
                contratRepository.save(sibling);
                log.info("Purchase contrat #{} (EN_COURS) cancelled due to sale completion of bien #{}",
                        sibling.getId(), bien.getId());
            }
        }

        // 4. Unlink the sale offer from the property
        bien.setAchat(null);
        bienRepository.save(bien);
    }

    private void createReconductionContract(Contrat oldContrat, Personne newOwner,
                                             Personne renter, Bien bien,
                                             Contrat purchaseContrat) {
        Contrat newContrat = new Contrat();
        newContrat.setBien(bien);
        newContrat.setTypeContrat(Contrat.TypeContrat.LOCATION);
        newContrat.setStatut(Contrat.StatutContrat.SIGNE);
        newContrat.setCreatedBy(securityUtils.getCurrentCompteOrThrow());

        // Copy snapshot from old contract
        newContrat.setSnapMensualite(oldContrat.getSnapMensualite());
        newContrat.setSnapCaution(oldContrat.getSnapCaution());
        newContrat.setSnapDureeMois(oldContrat.getSnapDureeMois());
        newContrat.setSnapDateDispo(oldContrat.getSnapDateDispo());

        // Add cosigners: new owner + renter
        Cosigner ownerCosigner = new Cosigner();
        ownerCosigner.setContrat(newContrat);
        ownerCosigner.setPersonne(newOwner);
        ownerCosigner.setId(new Cosigner.CosignerId());
        ownerCosigner.setTypeSignataire(Cosigner.TypeSignataire.OWNER);
        ownerCosigner.setDateSignature(LocalDateTime.now());
        newContrat.getCosigners().add(ownerCosigner);

        Cosigner renterCosigner = new Cosigner();
        renterCosigner.setContrat(newContrat);
        renterCosigner.setPersonne(renter);
        renterCosigner.setId(new Cosigner.CosignerId());
        renterCosigner.setTypeSignataire(Cosigner.TypeSignataire.RENTER);
        renterCosigner.setDateSignature(LocalDateTime.now());
        newContrat.getCosigners().add(renterCosigner);

        // Generate the reconduction PDF
        try {
            byte[] reconductionPdf = contratPdfService.generateReconductionPdf(
                    oldContrat, purchaseContrat, newOwner);

            Path uploadPath = Paths.get(uploadDir);
            Files.createDirectories(uploadPath);

            Contrat saved = contratRepository.saveAndFlush(newContrat);

            String filename = "contrat-" + saved.getId() + "-signe.pdf";
            Path filePath = uploadPath.resolve(filename);
            Files.write(filePath, reconductionPdf);

            saved.setDocumentSigne(filename);
            contratRepository.save(saved);

            log.info("Reconduction rental contrat #{} created for bien #{} (new owner: {} {}, renter: {} {})",
                    saved.getId(), bien.getId(),
                    newOwner.getPrenom(), newOwner.getNom(),
                    renter.getPrenom(), renter.getNom());
        } catch (IOException e) {
            log.error("Failed to generate reconduction PDF for contrat #{}: {}",
                    oldContrat.getId(), e.getMessage());
            Contrat saved = contratRepository.saveAndFlush(newContrat);
            log.warn("Reconduction contrat #{} created without PDF document", saved.getId());
        }
    }

    public ContratDTO confirmContrat(Long id) {
        Contrat contrat = contratRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));

        if (contrat.getStatut() != Contrat.StatutContrat.EN_COURS) {
            throw new IllegalArgumentException("Seul un contrat EN_COURS peut etre confirme.");
        }

        if (contrat.getDocumentSigne() == null || contrat.getDocumentSigne().isBlank()) {
            throw new IllegalArgumentException("Un document signe doit etre televerse avant de confirmer le contrat.");
        }

        contrat.setStatut(Contrat.StatutContrat.SIGNE);

        // Set signature date on all cosigners
        LocalDateTime now = LocalDateTime.now();
        for (Cosigner cosigner : contrat.getCosigners()) {
            cosigner.setDateSignature(now);
        }

        contratRepository.save(contrat);

        // Delete the corresponding offer
        Bien bien = contrat.getBien();
        if (contrat.getTypeContrat() == Contrat.TypeContrat.LOCATION && bien.getLocation() != null) {
            bien.setLocation(null);
            bienRepository.save(bien);
            log.info("Location offer deleted for bien #{} after contract #{} signed", bien.getId(), id);
        } else if (contrat.getTypeContrat() == Contrat.TypeContrat.ACHAT && bien.getAchat() != null) {
            bien.setAchat(null);
            bienRepository.save(bien);
            log.info("Achat offer deleted for bien #{} after contract #{} signed", bien.getId(), id);
        }

        // Cancel all other EN_COURS contracts of the same type for the same Bien
        List<Contrat> siblings = contratRepository.findByBienIdAndTypeContrat(bien.getId(), contrat.getTypeContrat());
        for (Contrat sibling : siblings) {
            if (!sibling.getId().equals(id) && sibling.getStatut() == Contrat.StatutContrat.EN_COURS) {
                sibling.setStatut(Contrat.StatutContrat.ANNULE);
                contratRepository.save(sibling);
                log.info("Sibling contrat #{} cancelled after contract #{} signed on bien #{}",
                        sibling.getId(), id, bien.getId());
            }
        }

        return convertToDTO(contrat);
    }

    public ContratDTO cancelContrat(Long id) {
        Contrat contrat = contratRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));

        if (contrat.getStatut() != Contrat.StatutContrat.EN_COURS) {
            throw new IllegalArgumentException("Seul un contrat EN_COURS peut etre annule.");
        }

        contrat.setStatut(Contrat.StatutContrat.ANNULE);
        Contrat saved = contratRepository.save(contrat);
        return convertToDTO(saved);
    }

    public void setDocumentSigne(Long id, String filePath) {
        Contrat contrat = contratRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Contrat not found with id: " + id));

        if (contrat.getStatut() == Contrat.StatutContrat.TERMINE) {
            throw new IllegalArgumentException("Un contrat termine ne peut plus etre modifie.");
        }
        if (contrat.getStatut() == Contrat.StatutContrat.SIGNE) {
            throw new IllegalArgumentException("Le document d'un contrat signe ne peut plus etre modifie.");
        }

        contrat.setDocumentSigne(filePath);
        contratRepository.save(contrat);
    }

    private ContratDTO convertToDTO(Contrat c) {
        ContratDTO dto = new ContratDTO();
        dto.setId(c.getId());
        dto.setDateCreation(c.getDateCreation());
        dto.setDateModification(c.getDateModification());
        dto.setStatut(c.getStatut().name());
        dto.setType(c.getTypeContrat() != null ? c.getTypeContrat().name() : null);
        dto.setHasSignedDocument(c.getDocumentSigne() != null && !c.getDocumentSigne().isBlank());

        // Snapshot fields
        dto.setSnapMensualite(c.getSnapMensualite());
        dto.setSnapCaution(c.getSnapCaution());
        dto.setSnapDureeMois(c.getSnapDureeMois());
        dto.setSnapPrix(c.getSnapPrix());
        dto.setSnapDateDispo(c.getSnapDateDispo());

        // Bien reference
        Bien bien = c.getBien();
        if (bien != null) {
            BienDTO bienDTO = new BienDTO();
            bienDTO.setId(bien.getId());
            bienDTO.setRue(bien.getRue());
            bienDTO.setVille(bien.getVille());
            bienDTO.setCodePostal(bien.getCodePostal());
            bienDTO.setType(bien.getType());
            bienDTO.setActif(bien.getActif());
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
        ContratDTO base = convertToDTO(c);
        dto.setId(base.getId());
        dto.setDateCreation(base.getDateCreation());
        dto.setDateModification(base.getDateModification());
        dto.setStatut(base.getStatut());
        dto.setType(base.getType());
        dto.setBien(base.getBien());
        dto.setHasSignedDocument(base.isHasSignedDocument());
        dto.setCosigners(base.getCosigners());
        dto.setSnapMensualite(base.getSnapMensualite());
        dto.setSnapCaution(base.getSnapCaution());
        dto.setSnapDureeMois(base.getSnapDureeMois());
        dto.setSnapPrix(base.getSnapPrix());
        dto.setSnapDateDispo(base.getSnapDateDispo());

        // Count other EN_COURS contracts of same type on same Bien
        List<Contrat> siblings = contratRepository.findByBienIdAndTypeContrat(c.getBien().getId(), c.getTypeContrat());
        int siblingCount = (int) siblings.stream()
                .filter(s -> !s.getId().equals(c.getId()) && s.getStatut() == Contrat.StatutContrat.EN_COURS)
                .count();
        dto.setSiblingContratCount(siblingCount);

        return dto;
    }
}
