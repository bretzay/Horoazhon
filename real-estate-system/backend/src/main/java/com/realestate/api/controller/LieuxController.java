package com.realestate.api.controller;

import com.realestate.api.dto.LieuDTO;
import com.realestate.api.service.LieuxService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import java.util.List;

@RestController
@RequestMapping("/api/lieux")
@RequiredArgsConstructor
public class LieuxController {

    private final LieuxService lieuxService;

    @GetMapping
    public ResponseEntity<List<LieuDTO>> getAll() {
        return ResponseEntity.ok(lieuxService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LieuDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(lieuxService.findById(id));
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<LieuDTO> create(@Valid @RequestBody LieuDTO request) {
        LieuDTO created = lieuxService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<LieuDTO> update(@PathVariable Long id, @Valid @RequestBody LieuDTO request) {
        return ResponseEntity.ok(lieuxService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        lieuxService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
