package com.realestate.api.controller;

import com.realestate.api.dto.CaracteristiqueDTO;
import com.realestate.api.service.CaracteristiquesService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import java.util.List;

@RestController
@RequestMapping("/api/caracteristiques")
@RequiredArgsConstructor
public class CaracteristiquesController {

    private final CaracteristiquesService caracteristiquesService;

    @GetMapping
    public ResponseEntity<List<CaracteristiqueDTO>> getAll() {
        return ResponseEntity.ok(caracteristiquesService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CaracteristiqueDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(caracteristiquesService.findById(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<CaracteristiqueDTO> create(@Valid @RequestBody CaracteristiqueDTO request) {
        CaracteristiqueDTO created = caracteristiquesService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<CaracteristiqueDTO> update(@PathVariable Long id, @Valid @RequestBody CaracteristiqueDTO request) {
        return ResponseEntity.ok(caracteristiquesService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        caracteristiquesService.delete(id);
        return ResponseEntity.noContent().build();
    }
}