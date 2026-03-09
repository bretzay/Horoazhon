package com.realestate.api.controller;

import com.realestate.api.dto.AgenceDTO;
import com.realestate.api.dto.BienDTO;
import com.realestate.api.entity.Compte;
import com.realestate.api.security.SecurityUtils;
import com.realestate.api.service.AgenceService;
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
import org.springframework.security.access.prepost.PreAuthorize;
import java.util.List;

@RestController
@RequestMapping("/api/agences")
@RequiredArgsConstructor
public class AgenceController {

    private final AgenceService agenceService;
    private final BienService bienService;
    private final SecurityUtils securityUtils;

    @GetMapping
    public ResponseEntity<List<AgenceDTO>> getAllAgences() {
        return ResponseEntity.ok(agenceService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AgenceDTO> getAgenceById(@PathVariable Long id) {
        return ResponseEntity.ok(agenceService.findById(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<AgenceDTO> createAgence(@Valid @RequestBody AgenceDTO request) {
        AgenceDTO created = agenceService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN', 'ROLE_ADMIN_AGENCY')")
    public ResponseEntity<AgenceDTO> updateAgence(@PathVariable Long id, @Valid @RequestBody AgenceDTO request) {
        // ADMIN_AGENCY can only update their own agency
        Compte compte = securityUtils.getCurrentCompteOrThrow();
        if (compte.getRole() == Compte.Role.ADMIN_AGENCY) {
            Long userAgenceId = securityUtils.getCurrentAgenceId();
            if (!id.equals(userAgenceId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }
        return ResponseEntity.ok(agenceService.update(id, request));
    }

    @GetMapping("/{id}/biens")
    public ResponseEntity<Page<BienDTO>> getAgenceBiens(
        @PathVariable Long id,
        @RequestParam(required = false) Boolean actif,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "12") int size
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        return ResponseEntity.ok(bienService.findByAgenceId(id, actif, pageable));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<Void> deleteAgence(@PathVariable Long id) {
        agenceService.delete(id);
        return ResponseEntity.noContent().build();
    }
}