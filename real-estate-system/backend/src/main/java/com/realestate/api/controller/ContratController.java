package com.realestate.api.controller;

import com.realestate.api.dto.ContratDTO;
import com.realestate.api.dto.ContratDetailDTO;
import com.realestate.api.dto.CreateContratRequest;
import com.realestate.api.service.ContratService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/contrats")
@RequiredArgsConstructor
public class ContratController {

    private final ContratService contratService;

    @GetMapping
    public ResponseEntity<Page<ContratDTO>> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        return ResponseEntity.ok(contratService.findAll(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContratDetailDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(contratService.findById(id));
    }

    @PostMapping
    public ResponseEntity<ContratDTO> create(@Valid @RequestBody CreateContratRequest request) {
        ContratDTO created = contratService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PatchMapping("/{id}/statut")
    public ResponseEntity<ContratDTO> updateStatut(@PathVariable Long id, @RequestParam String statut) {
        return ResponseEntity.ok(contratService.updateStatut(id, statut));
    }
}
