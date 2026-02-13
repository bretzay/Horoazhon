package com.realestate.api.controller;

import com.realestate.api.dto.AchatDTO;
import com.realestate.api.dto.CreateAchatRequest;
import com.realestate.api.service.AchatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/achats")
@RequiredArgsConstructor
public class AchatController {

    private final AchatService achatService;

    @GetMapping
    public ResponseEntity<List<AchatDTO>> getAll() {
        return ResponseEntity.ok(achatService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AchatDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(achatService.findById(id));
    }

    @PostMapping
    public ResponseEntity<AchatDTO> create(@Valid @RequestBody CreateAchatRequest request) {
        AchatDTO created = achatService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        achatService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
