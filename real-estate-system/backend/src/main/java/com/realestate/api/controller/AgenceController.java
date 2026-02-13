package com.realestate.api.controller;

import com.realestate.api.dto.AgenceDTO;
import com.realestate.api.service.AgenceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/agences")
@RequiredArgsConstructor
public class AgenceController {

    private final AgenceService agenceService;

    @GetMapping
    public ResponseEntity<List<AgenceDTO>> getAllAgences() {
        return ResponseEntity.ok(agenceService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AgenceDTO> getAgenceById(@PathVariable Long id) {
        return ResponseEntity.ok(agenceService.findById(id));
    }

    @PostMapping
    public ResponseEntity<AgenceDTO> createAgence(@Valid @RequestBody AgenceDTO request) {
        AgenceDTO created = agenceService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AgenceDTO> updateAgence(@PathVariable Long id, @Valid @RequestBody AgenceDTO request) {
        return ResponseEntity.ok(agenceService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAgence(@PathVariable Long id) {
        agenceService.delete(id);
        return ResponseEntity.noContent().build();
    }
}