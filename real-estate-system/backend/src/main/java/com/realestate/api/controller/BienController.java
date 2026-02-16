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
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.math.BigDecimal;

@RestController
@RequestMapping("/api/biens")
@RequiredArgsConstructor
public class BienController {

    private final BienService bienService;

    @GetMapping
    public ResponseEntity<Page<BienDTO>> getAllBiens(
        @RequestParam(required = false) String ville,
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
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        @RequestParam(defaultValue = "dateCreation,desc") String[] sort
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        Page<BienDTO> biens = bienService.findAll(
            ville, type, prixMin, prixMax, forSale, forRent,
            caracId, caracMin, lieuId, maxMinutes, locomotion,
            pageable
        );
        return ResponseEntity.ok(biens);
    }

    @GetMapping("/{id}")
    public ResponseEntity<BienDetailDTO> getBienById(@PathVariable Long id) {
        BienDetailDTO bien = bienService.findById(id);
        return ResponseEntity.ok(bien);
    }

    @PostMapping
    public ResponseEntity<BienDTO> createBien(@Valid @RequestBody CreateBienRequest request) {
        BienDTO created = bienService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<BienDTO> updateBien(@PathVariable Long id, @Valid @RequestBody UpdateBienRequest request) {
        BienDTO updated = bienService.update(id, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBien(@PathVariable Long id) {
        bienService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // ===== Caracteristiques associations =====

    @PostMapping("/{bienId}/caracteristiques")
    public ResponseEntity<Void> addCaracteristique(
            @PathVariable Long bienId,
            @RequestParam Long caracteristiqueId,
            @RequestParam String valeur,
            @RequestParam(required = false) String unite) {
        bienService.addCaracteristique(bienId, caracteristiqueId, valeur, unite);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{bienId}/caracteristiques/{caracteristiqueId}")
    public ResponseEntity<Void> removeCaracteristique(
            @PathVariable Long bienId,
            @PathVariable Long caracteristiqueId) {
        bienService.removeCaracteristique(bienId, caracteristiqueId);
        return ResponseEntity.noContent().build();
    }

    // ===== Lieux associations =====

    @PostMapping("/{bienId}/lieux")
    public ResponseEntity<Void> addLieu(
            @PathVariable Long bienId,
            @RequestParam Long lieuId,
            @RequestParam Integer minutes,
            @RequestParam(required = false) String typeLocomotion) {
        bienService.addLieu(bienId, lieuId, minutes, typeLocomotion);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{bienId}/lieux/{lieuId}")
    public ResponseEntity<Void> removeLieu(
            @PathVariable Long bienId,
            @PathVariable Long lieuId) {
        bienService.removeLieu(bienId, lieuId);
        return ResponseEntity.noContent().build();
    }

    // ===== Proprietaire (single owner) =====

    @PutMapping("/{bienId}/proprietaire")
    public ResponseEntity<Void> setProprietaire(
            @PathVariable Long bienId,
            @RequestParam Long personneId) {
        bienService.setProprietaire(bienId, personneId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{bienId}/proprietaire")
    public ResponseEntity<Void> removeProprietaire(
            @PathVariable Long bienId) {
        bienService.removeProprietaire(bienId);
        return ResponseEntity.noContent().build();
    }

    // ===== Photos =====

    @PostMapping("/{bienId}/photos")
    public ResponseEntity<PhotoDTO> addPhoto(
            @PathVariable Long bienId,
            @RequestParam String chemin,
            @RequestParam(required = false) Integer ordre) {
        PhotoDTO photo = bienService.addPhoto(bienId, chemin, ordre);
        return ResponseEntity.status(HttpStatus.CREATED).body(photo);
    }

    @DeleteMapping("/{bienId}/photos/{photoId}")
    public ResponseEntity<Void> removePhoto(
            @PathVariable Long bienId,
            @PathVariable Long photoId) {
        bienService.removePhoto(bienId, photoId);
        return ResponseEntity.noContent().build();
    }
}