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
import java.nio.file.StandardCopyOption;
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
        if (request.getCosigners() == null || request.getCosigners().size() != 2) {
            throw new IllegalArgumentException("A contract must have exactly 2 cosigners");
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
        contrat.setCreatedBy(securityUtils.getCurrentCompteOrThrow());

        // Add cosigners before first save so cascade persists them
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

        // TERMINE contracts are frozen — no modifications allowed
        if (currentStatut == Contrat.StatutContrat.TERMINE) {
            throw new IllegalArgumentException("Un contrat termine ne peut plus etre modifie.");
        }

        // SIGNE contracts can only be terminated
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

    /**
     * When a purchase contract is completed (TERMINE):
     * 1. Transfer property ownership from seller to buyer
     * 2. Terminate any active (SIGNE) rental contracts on this property early
     * 3. Create reconduction rental contracts with the new owner
     * 4. Delete the rental offer (Location) on the property
     * 5. Cancel any EN_COURS rental contracts on this property
     */
    private void handlePurchaseCompletion(Contrat purchaseContrat) {
        Bien bien = purchaseContrat.getAchat().getBien();
        LocalDateTime now = LocalDateTime.now();

        // Find buyer and seller from cosigners
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

        // 2 & 3. Handle active rental contracts on this property
        Location location = bien.getLocation();
        if (location != null) {
            List<Contrat> rentalContracts = contratRepository.findByLocationId(location.getId());

            for (Contrat rentalContrat : rentalContracts) {
                if (rentalContrat.getStatut() == Contrat.StatutContrat.SIGNE) {
                    // Terminate early
                    rentalContrat.setStatut(Contrat.StatutContrat.TERMINE);
                    contratRepository.save(rentalContrat);

                    log.info("Rental contrat #{} terminated early due to sale of bien #{}",
                            rentalContrat.getId(), bien.getId());

                    // Find the renter from the old contract
                    Personne renter = null;
                    for (Cosigner cs : rentalContrat.getCosigners()) {
                        if (cs.getTypeSignataire() == Cosigner.TypeSignataire.RENTER) {
                            renter = cs.getPersonne();
                            break;
                        }
                    }

                    if (renter != null) {
                        // Create reconduction contract with new owner
                        createReconductionContract(rentalContrat, buyer, renter, location, purchaseContrat);
                    }
                } else if (rentalContrat.getStatut() == Contrat.StatutContrat.EN_COURS) {
                    // Cancel any pending rental contracts
                    rentalContrat.setStatut(Contrat.StatutContrat.ANNULE);
                    contratRepository.save(rentalContrat);

                    log.info("Rental contrat #{} (EN_COURS) cancelled due to sale of bien #{}",
                            rentalContrat.getId(), bien.getId());
                }
            }

            // 4. Unlink the rental offer from the property (keep the Location entity
            //    because existing contracts reference it via foreign key)
            bien.setLocation(null);
            bienRepository.save(bien);

            log.info("Rental offer (location #{}) unlinked from bien #{} after sale",
                    location.getId(), bien.getId());
        }

        // Also delete the sale offer (Achat) since the sale is complete
        Achat achat = purchaseContrat.getAchat();
        bien.setAchat(null);
        bienRepository.save(bien);
        // Don't delete the achat entity since existing contracts reference it
    }

    /**
     * Create a reconduction rental contract with the new owner after property sale.
     * The new contract:
     * - References the same Location
     * - Has the buyer (new owner) as OWNER and the renter as RENTER
     * - Is set directly to SIGNE status
     * - Uses the old contract's signed document + a reconduction note page
     * - Keeps the same duration (or null if indefinite)
     */
    private void createReconductionContract(Contrat oldContrat, Personne newOwner,
                                             Personne renter, Location location,
                                             Contrat purchaseContrat) {
        Contrat newContrat = new Contrat();
        newContrat.setLocation(location);
        newContrat.setStatut(Contrat.StatutContrat.SIGNE);
        newContrat.setCreatedBy(securityUtils.getCurrentCompteOrThrow());

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

        // Generate the reconduction PDF: old contract's document + reconduction note
        try {
            byte[] reconductionPdf = contratPdfService.generateReconductionPdf(
                    oldContrat, purchaseContrat, newOwner);

            Path uploadPath = Paths.get(uploadDir);
            Files.createDirectories(uploadPath);

            // Save temporarily to get the contrat ID after flush
            Contrat saved = contratRepository.saveAndFlush(newContrat);

            String filename = "contrat-" + saved.getId() + "-signe.pdf";
            Path filePath = uploadPath.resolve(filename);
            Files.write(filePath, reconductionPdf);

            saved.setDocumentSigne(filename);
            contratRepository.save(saved);

            log.info("Reconduction rental contrat #{} created for bien #{} (new owner: {} {}, renter: {} {})",
                    saved.getId(), location.getBien().getId(),
                    newOwner.getPrenom(), newOwner.getNom(),
                    renter.getPrenom(), renter.getNom());
        } catch (IOException e) {
            log.error("Failed to generate reconduction PDF for contrat #{}: {}",
                    oldContrat.getId(), e.getMessage());
            // Still create the contract but without the PDF
            Contrat saved = contratRepository.saveAndFlush(newContrat);
            log.warn("Reconduction contrat #{} created without PDF document", saved.getId());
        }
    }

    public ContratDTO confirmContrat(Long id) {
        Contrat contrat = contratRepository.findById(id)
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

        // Cancel all other EN_COURS contracts on the same offer
        List<Contrat> siblings;
        if (contrat.getLocation() != null) {
            siblings = contratRepository.findByLocationId(contrat.getLocation().getId());
        } else {
            siblings = contratRepository.findByAchatId(contrat.getAchat().getId());
        }
        for (Contrat sibling : siblings) {
            if (!sibling.getId().equals(id) && sibling.getStatut() == Contrat.StatutContrat.EN_COURS) {
                sibling.setStatut(Contrat.StatutContrat.ANNULE);
                contratRepository.save(sibling);
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
        dto.setType(c.getType() != null ? c.getType().name() : null);
        dto.setHasSignedDocument(c.getDocumentSigne() != null && !c.getDocumentSigne().isBlank());

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
        dto.setHasSignedDocument(base.isHasSignedDocument());
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

        // Count other EN_COURS contracts on the same offer
        List<Contrat> siblings;
        if (c.getLocation() != null) {
            siblings = contratRepository.findByLocationId(c.getLocation().getId());
        } else if (c.getAchat() != null) {
            siblings = contratRepository.findByAchatId(c.getAchat().getId());
        } else {
            siblings = List.of();
        }
        int siblingCount = (int) siblings.stream()
                .filter(s -> !s.getId().equals(c.getId()) && s.getStatut() == Contrat.StatutContrat.EN_COURS)
                .count();
        dto.setSiblingContratCount(siblingCount);

        return dto;
    }
}
