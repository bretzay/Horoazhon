package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.*;
import com.realestate.api.repository.*;
import com.realestate.api.security.SecurityUtils;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.TypedQuery;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class BienService {

    private final BienRepository bienRepository;
    private final AgenceRepository agenceRepository;
    private final SecurityUtils securityUtils;
    private final CaracteristiquesRepository caracteristiquesRepository;
    private final ContenirRepository contenirRepository;
    private final LieuxRepository lieuxRepository;
    private final DeplacerRepository deplacerRepository;
    private final PersonneRepository personneRepository;
    private final PossederRepository possederRepository;
    private final PhotoRepository photoRepository;
    private final ContratRepository contratRepository;
    private final EntityManager entityManager;

    @Transactional(readOnly = true)
    public Page<BienDTO> findAll(
            String search,
            String type,
            BigDecimal prixMin,
            BigDecimal prixMax,
            Boolean forSale,
            Boolean forRent,
            Long caracId,
            Integer caracMin,
            Long lieuId,
            Integer maxMinutes,
            String locomotion,
            Map<String, String> allParams,
            Pageable pageable
    ) {
        // Extract multi-characteristic filters: caracMin_1, caracMin_2, etc.
        Map<Long, Integer> caracFilters = new LinkedHashMap<>();
        // Legacy single filter
        if (caracId != null) {
            caracFilters.put(caracId, caracMin);
        }
        // New per-characteristic filters
        for (Map.Entry<String, String> entry : allParams.entrySet()) {
            if (entry.getKey().startsWith("caracMin_") && entry.getValue() != null && !entry.getValue().isBlank()) {
                try {
                    Long cId = Long.parseLong(entry.getKey().substring("caracMin_".length()));
                    Integer cMin = Integer.parseInt(entry.getValue());
                    caracFilters.put(cId, cMin);
                } catch (NumberFormatException ignored) {}
            }
        }

        // Extract multi-lieu filters: lieuMax_ID=minutes, lieuLoco_ID=locomotion
        // Each entry: lieuId -> (maxMinutes, locomotion)
        Map<Long, int[]> lieuMinutesMap = new LinkedHashMap<>();
        Map<Long, String> lieuLocoMap = new LinkedHashMap<>();
        // Legacy single filter
        if (lieuId != null) {
            lieuMinutesMap.put(lieuId, new int[]{maxMinutes != null ? maxMinutes : Integer.MAX_VALUE});
            if (locomotion != null && !locomotion.isBlank()) {
                lieuLocoMap.put(lieuId, locomotion);
            }
        }
        // New per-lieu filters
        for (Map.Entry<String, String> entry : allParams.entrySet()) {
            if (entry.getKey().startsWith("lieuMax_") && entry.getValue() != null && !entry.getValue().isBlank()) {
                try {
                    Long lId = Long.parseLong(entry.getKey().substring("lieuMax_".length()));
                    Integer lMax = Integer.parseInt(entry.getValue());
                    lieuMinutesMap.put(lId, new int[]{lMax});
                } catch (NumberFormatException ignored) {}
            }
            if (entry.getKey().startsWith("lieuLoco_") && entry.getValue() != null && !entry.getValue().isBlank()) {
                try {
                    Long lId = Long.parseLong(entry.getKey().substring("lieuLoco_".length()));
                    lieuLocoMap.put(lId, entry.getValue());
                } catch (NumberFormatException ignored) {}
            }
        }

        // Build dynamic JPQL
        StringBuilder jpql = new StringBuilder();
        jpql.append("SELECT DISTINCT b FROM Bien b ");
        jpql.append("LEFT JOIN b.achat a ");
        jpql.append("LEFT JOIN b.location l ");
        jpql.append("WHERE 1=1 ");

        Map<String, Object> params = new HashMap<>();

        // Agency filter (skip for unauthenticated public access)
        Long agenceId = securityUtils.isAuthenticated() ? securityUtils.getCurrentAgenceId() : null;
        if (agenceId != null) {
            jpql.append("AND b.agence.id = :agenceId ");
            params.put("agenceId", agenceId);
        }

        // Search terms
        if (search != null && !search.isBlank()) {
            String[] words = search.trim().toLowerCase().split("\\s+");
            for (int i = 0; i < Math.min(words.length, 5); i++) {
                String paramName = "s" + i;
                jpql.append("AND LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :").append(paramName).append(" ");
                params.put(paramName, "%" + words[i] + "%");
            }
        }

        // Type filter
        if (type != null && !type.isBlank()) {
            jpql.append("AND b.type = :type ");
            params.put("type", type);
        }

        // Sale/Rent
        if (forSale != null && forSale) {
            jpql.append("AND a IS NOT NULL ");
        }
        if (forRent != null && forRent) {
            jpql.append("AND l IS NOT NULL ");
        }

        // Price
        if (prixMin != null) {
            jpql.append("AND (a.prix >= :prixMin OR l.mensualite >= :prixMin) ");
            params.put("prixMin", prixMin);
        }
        if (prixMax != null) {
            jpql.append("AND (a.prix <= :prixMax OR l.mensualite <= :prixMax) ");
            params.put("prixMax", prixMax);
        }

        // Characteristic filters (AND logic: all must match)
        int ci = 0;
        for (Map.Entry<Long, Integer> cf : caracFilters.entrySet()) {
            String idParam = "cId" + ci;
            String minParam = "cMin" + ci;
            jpql.append("AND EXISTS (SELECT ct").append(ci).append(" FROM Contenir ct").append(ci)
                .append(" WHERE ct").append(ci).append(".bien = b AND ct").append(ci)
                .append(".caracteristique.id = :").append(idParam);
            params.put(idParam, cf.getKey());
            if (cf.getValue() != null) {
                jpql.append(" AND CAST(ct").append(ci).append(".valeur AS Integer) >= :").append(minParam);
                params.put(minParam, cf.getValue());
            }
            jpql.append(") ");
            ci++;
        }

        // Lieu filters (AND logic: all must match)
        // Speed ranking: slower modes that meet the time constraint imply faster modes also do
        // MARCHE/A_PIED (slowest) < VELO < TRANSPORT_PUBLIC < VOITURE (fastest)
        int li = 0;
        for (Map.Entry<Long, int[]> lf : lieuMinutesMap.entrySet()) {
            Long lId = lf.getKey();
            int lMax = lf.getValue()[0];
            String loco = lieuLocoMap.get(lId);

            String idParam = "lId" + li;
            String maxParam = "lMax" + li;
            jpql.append("AND EXISTS (SELECT d").append(li).append(" FROM Deplacer d").append(li)
                .append(" WHERE d").append(li).append(".bien = b AND d").append(li)
                .append(".lieu.id = :").append(idParam);
            params.put(idParam, lId);

            if (lMax < Integer.MAX_VALUE) {
                jpql.append(" AND d").append(li).append(".minutes <= :").append(maxParam);
                params.put(maxParam, lMax);
            }

            if (loco != null && !loco.isBlank()) {
                // Include the selected mode and all slower modes
                List<String> acceptable = getAcceptableLocomotions(loco);
                String locoParam = "lLocos" + li;
                jpql.append(" AND d").append(li).append(".typeLocomotion IN :").append(locoParam);
                params.put(locoParam, acceptable);
            }

            jpql.append(") ");
            li++;
        }

        // Count query
        String countJpql = jpql.toString().replace("SELECT DISTINCT b", "SELECT COUNT(DISTINCT b)");
        TypedQuery<Long> countQuery = entityManager.createQuery(countJpql, Long.class);
        params.forEach(countQuery::setParameter);
        long total = countQuery.getSingleResult();

        // Data query with sorting and pagination
        jpql.append("ORDER BY b.dateCreation DESC");
        TypedQuery<Bien> dataQuery = entityManager.createQuery(jpql.toString(), Bien.class);
        params.forEach(dataQuery::setParameter);
        dataQuery.setFirstResult((int) pageable.getOffset());
        dataQuery.setMaxResults(pageable.getPageSize());

        List<Bien> results = dataQuery.getResultList();
        List<BienDTO> dtos = results.stream().map(this::convertToDTO).collect(Collectors.toList());
        return new PageImpl<>(dtos, pageable, total);
    }

    @Transactional(readOnly = true)
    public BienDetailDTO findById(Long id) {
        Bien bien = bienRepository.findByIdWithDetails(id)
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

        // SUPER_ADMIN must provide agenceId; others auto-link to their own agency
        Long agenceId = securityUtils.getCurrentAgenceId();
        if (agenceId != null) {
            Agence agence = agenceRepository.findById(agenceId)
                .orElseThrow(() -> new EntityNotFoundException("Agence not found"));
            bien.setAgence(agence);
        } else if (request.getAgenceId() != null) {
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

        verifyAgencyAccess(bien);

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

    @Transactional(readOnly = true)
    public Page<BienDTO> findByAgenceId(Long agenceId, Pageable pageable) {
        return bienRepository.findByAgenceId(agenceId, pageable).map(this::convertToDTO);
    }

    public void delete(Long id) {
        Bien bien = bienRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + id));
        verifyAgencyAccess(bien);
        bienRepository.deleteById(id);
    }

    /**
     * Verify the current user has access to modify this property.
     * SUPER_ADMIN can modify any property. Others can only modify properties in their agency.
     */
    private void verifyAgencyAccess(Bien bien) {
        Long currentAgenceId = securityUtils.getCurrentAgenceId();
        if (currentAgenceId != null && bien.getAgence() != null
                && !bien.getAgence().getId().equals(currentAgenceId)) {
            throw new AccessDeniedException("Vous n'avez pas acces aux biens d'une autre agence.");
        }
    }

    // ===== Caracteristiques associations =====

    public void addCaracteristique(Long bienId, Long caracteristiqueId, String valeur, String unite) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        Caracteristiques carac = caracteristiquesRepository.findById(caracteristiqueId)
            .orElseThrow(() -> new EntityNotFoundException("Caracteristique not found with id: " + caracteristiqueId));

        Contenir.ContenirId id = new Contenir.ContenirId(bienId, caracteristiqueId);
        if (contenirRepository.existsById(id)) {
            throw new IllegalStateException("Cette caracteristique est deja associee a ce bien.");
        }

        Contenir contenir = new Contenir();
        contenir.setId(id);
        contenir.setBien(bien);
        contenir.setCaracteristique(carac);
        contenir.setValeur(valeur);
        contenir.setUnite(unite);
        contenirRepository.save(contenir);
    }

    public void removeCaracteristique(Long bienId, Long caracteristiqueId) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        Contenir.ContenirId id = new Contenir.ContenirId(bienId, caracteristiqueId);
        if (!contenirRepository.existsById(id)) {
            throw new EntityNotFoundException("Association not found.");
        }
        contenirRepository.deleteById(id);
    }

    // ===== Lieux associations =====

    public void addLieu(Long bienId, Long lieuId, Integer minutes, String typeLocomotion) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        Lieux lieu = lieuxRepository.findById(lieuId)
            .orElseThrow(() -> new EntityNotFoundException("Lieu not found with id: " + lieuId));

        Deplacer.DeplacerId id = new Deplacer.DeplacerId(bienId, lieuId);
        if (deplacerRepository.existsById(id)) {
            throw new IllegalStateException("Ce lieu est deja associe a ce bien.");
        }

        Deplacer deplacer = new Deplacer();
        deplacer.setId(id);
        deplacer.setBien(bien);
        deplacer.setLieu(lieu);
        deplacer.setMinutes(minutes);
        deplacer.setTypeLocomotion(typeLocomotion);
        deplacerRepository.save(deplacer);
    }

    public void removeLieu(Long bienId, Long lieuId) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        Deplacer.DeplacerId id = new Deplacer.DeplacerId(bienId, lieuId);
        if (!deplacerRepository.existsById(id)) {
            throw new EntityNotFoundException("Association not found.");
        }
        deplacerRepository.deleteById(id);
    }

    // ===== Proprietaire (single owner per property) =====

    public void setProprietaire(Long bienId, Long personneId) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        Personne personne = personneRepository.findById(personneId)
            .orElseThrow(() -> new EntityNotFoundException("Personne not found with id: " + personneId));

        // Remove existing owner(s) first
        possederRepository.deleteByBienId(bienId);
        possederRepository.flush();

        Posseder posseder = new Posseder();
        posseder.setId(new Posseder.PossederId(bienId, personneId));
        posseder.setBien(bien);
        posseder.setPersonne(personne);
        possederRepository.save(posseder);
    }

    public void removeProprietaire(Long bienId) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        possederRepository.deleteByBienId(bienId);
    }

    // ===== Photos =====

    public PhotoDTO addPhoto(Long bienId, String chemin, Integer ordre) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);

        Photo photo = new Photo();
        photo.setBien(bien);
        photo.setChemin(chemin);
        photo.setOrdre(ordre != null ? ordre : 1);

        Photo saved = photoRepository.save(photo);
        PhotoDTO dto = new PhotoDTO();
        dto.setId(saved.getId());
        dto.setChemin(saved.getChemin());
        dto.setOrdre(saved.getOrdre());
        dto.setUrl(saved.getChemin());
        dto.setDateCreation(saved.getDateCreation());
        return dto;
    }

    public void removePhoto(Long bienId, Long photoId) {
        Bien bien = bienRepository.findById(bienId)
            .orElseThrow(() -> new EntityNotFoundException("Bien not found with id: " + bienId));
        verifyAgencyAccess(bien);
        Photo photo = photoRepository.findById(photoId)
            .orElseThrow(() -> new EntityNotFoundException("Photo not found with id: " + photoId));
        if (!photo.getBien().getId().equals(bienId)) {
            throw new IllegalArgumentException("Photo does not belong to this bien.");
        }
        photoRepository.deleteById(photoId);
    }

    @Transactional(readOnly = true)
    public List<ContratDTO> findContratsByBien(Long bienId) {
        if (!bienRepository.existsById(bienId)) {
            throw new EntityNotFoundException("Bien not found with id: " + bienId);
        }
        return contratRepository.findByBienId(bienId).stream()
                .map(this::convertContratToDTO)
                .collect(Collectors.toList());
    }

    private ContratDTO convertContratToDTO(Contrat c) {
        ContratDTO dto = new ContratDTO();
        dto.setId(c.getId());
        dto.setDateCreation(c.getDateCreation());
        dto.setDateModification(c.getDateModification());
        dto.setStatut(c.getStatut().name());
        dto.setType(c.getType() != null ? c.getType().name() : null);
        dto.setHasSignedDocument(c.getDocumentSigne() != null && !c.getDocumentSigne().isBlank());

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

    /**
     * Returns the selected locomotion and all slower modes.
     * Speed: VOITURE > TRANSPORT_PUBLIC > VELO > MARCHE/A_PIED
     * If the user asks for VOITURE <= 5min, a property reachable A_PIED in 3min also qualifies.
     */
    private List<String> getAcceptableLocomotions(String selected) {
        // Ordered slowest to fastest
        List<String> ordered = List.of("A_PIED", "MARCHE", "VELO", "TRANSPORT_PUBLIC", "VOITURE");
        int selectedRank = ordered.indexOf(selected);
        if (selectedRank < 0) {
            return List.of(selected); // unknown value, match exactly
        }
        // Include everything from rank 0 up to and including the selected rank
        return ordered.subList(0, selectedRank + 1);
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
            agenceDTO.setNumeroTva(bien.getAgence().getNumeroTva());
            agenceDTO.setRue(bien.getAgence().getRue());
            agenceDTO.setVille(bien.getAgence().getVille());
            agenceDTO.setCodePostal(bien.getAgence().getCodePostal());
            agenceDTO.setTelephone(bien.getAgence().getTelephone());
            agenceDTO.setEmail(bien.getAgence().getEmail());
            dto.setAgence(agenceDTO);
        }

        Photo principal = bien.getPrincipalPhoto();
        if (principal != null) {
            dto.setPrincipalPhotoUrl(principal.getChemin());
        }
        if (bien.getPhotos() != null) {
            dto.setPhotoUrls(bien.getPhotos().stream()
                    .sorted((a, b) -> Integer.compare(
                            a.getOrdre() != null ? a.getOrdre() : Integer.MAX_VALUE,
                            b.getOrdre() != null ? b.getOrdre() : Integer.MAX_VALUE))
                    .map(Photo::getChemin)
                    .collect(Collectors.toList()));
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
            agenceDTO.setNumeroTva(bien.getAgence().getNumeroTva());
            agenceDTO.setRue(bien.getAgence().getRue());
            agenceDTO.setVille(bien.getAgence().getVille());
            agenceDTO.setCodePostal(bien.getAgence().getCodePostal());
            agenceDTO.setTelephone(bien.getAgence().getTelephone());
            agenceDTO.setEmail(bien.getAgence().getEmail());
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
