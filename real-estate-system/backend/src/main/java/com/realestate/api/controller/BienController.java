package com.realestate.api.controller;

import com.realestate.api.dto.*;
import com.realestate.api.service.BienService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/biens")
@RequiredArgsConstructor
public class BienController {

    private final BienService bienService;

    @GetMapping
    public ResponseEntity<Page<BienDTO>> getAllBiens(
        @RequestParam(required = false) String search,
        @RequestParam(required = false) String type,
        @RequestParam(required = false) BigDecimal prixMin,
        @RequestParam(required = false) BigDecimal prixMax,
        @RequestParam(required = false) Boolean forSale,
        @RequestParam(required = false) Boolean forRent,
        @RequestParam(required = false) Long caracId,
        @RequestParam(required = false) Integer caracMin,
        @RequestParam(required = false) Long lieuId,
        @RequestParam(required = false) Integer maxMinutes,
        @RequestParam(required = false) String locomotion,
        @RequestParam(required = false) Boolean actif,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        @RequestParam(defaultValue = "dateCreation,desc") String[] sort,
        @RequestParam Map<String, String> allParams
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        Page<BienDTO> biens = bienService.findAll(
            search, type, prixMin, prixMax, forSale, forRent,
            caracId, caracMin, lieuId, maxMinutes, locomotion,
            actif, allParams, pageable
        );
        return ResponseEntity.ok(biens);
    }

    @GetMapping("/{id}")
    public ResponseEntity<BienDetailDTO> getBienById(@PathVariable Long id) {
        BienDetailDTO bien = bienService.findById(id);
        return ResponseEntity.ok(bien);
    }

    @GetMapping("/{bienId}/contrats")
    public ResponseEntity<List<ContratDTO>> getContratsByBien(@PathVariable Long bienId) {
        List<ContratDTO> contrats = bienService.findContratsByBien(bienId);
        return ResponseEntity.ok(contrats);
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<BienDTO> createBien(@Valid @RequestBody CreateBienRequest request) {
        BienDTO created = bienService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<BienDTO> updateBien(@PathVariable Long id, @Valid @RequestBody UpdateBienRequest request) {
        BienDTO updated = bienService.update(id, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> deleteBien(@PathVariable Long id) {
        bienService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/archive")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<BienDTO> archiveBien(@PathVariable Long id) {
        BienDTO archived = bienService.archiveBien(id);
        return ResponseEntity.ok(archived);
    }

    @PutMapping("/{id}/unarchive")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<BienDTO> unarchiveBien(@PathVariable Long id) {
        BienDTO unarchived = bienService.unarchiveBien(id);
        return ResponseEntity.ok(unarchived);
    }

    // ===== Caracteristiques associations =====

    @PostMapping("/{bienId}/caracteristiques")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> addCaracteristique(
            @PathVariable Long bienId,
            @RequestParam Long caracteristiqueId,
            @RequestParam String valeur,
            @RequestParam(required = false) String unite) {
        bienService.addCaracteristique(bienId, caracteristiqueId, valeur, unite);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{bienId}/caracteristiques/{caracteristiqueId}")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> removeCaracteristique(
            @PathVariable Long bienId,
            @PathVariable Long caracteristiqueId) {
        bienService.removeCaracteristique(bienId, caracteristiqueId);
        return ResponseEntity.noContent().build();
    }

    // ===== Lieux associations =====

    @PostMapping("/{bienId}/lieux")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> addLieu(
            @PathVariable Long bienId,
            @RequestParam Long lieuId,
            @RequestParam Integer minutes,
            @RequestParam(required = false) String typeLocomotion) {
        bienService.addLieu(bienId, lieuId, minutes, typeLocomotion);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{bienId}/lieux/{lieuId}")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> removeLieu(
            @PathVariable Long bienId,
            @PathVariable Long lieuId) {
        bienService.removeLieu(bienId, lieuId);
        return ResponseEntity.noContent().build();
    }

    // ===== Proprietaire (single owner) =====

    @PutMapping("/{bienId}/proprietaire")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> setProprietaire(
            @PathVariable Long bienId,
            @RequestParam Long personneId) {
        bienService.setProprietaire(bienId, personneId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{bienId}/proprietaire")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> removeProprietaire(
            @PathVariable Long bienId) {
        bienService.removeProprietaire(bienId);
        return ResponseEntity.noContent().build();
    }

    // ===== Photos =====

    @PostMapping("/{bienId}/photos")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<PhotoDTO> addPhoto(
            @PathVariable Long bienId,
            @RequestParam String chemin,
            @RequestParam(required = false) Integer ordre) {
        PhotoDTO photo = bienService.addPhoto(bienId, chemin, ordre);
        return ResponseEntity.status(HttpStatus.CREATED).body(photo);
    }

    @DeleteMapping("/{bienId}/photos/{photoId}")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")
    public ResponseEntity<Void> removePhoto(
            @PathVariable Long bienId,
            @PathVariable Long photoId) {
        bienService.removePhoto(bienId, photoId);
        return ResponseEntity.noContent().build();
    }
}
