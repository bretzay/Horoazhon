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
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        @RequestParam(defaultValue = "dateCreation,desc") String[] sort
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        Page<BienDTO> biens = bienService.findAll(ville, type, prixMin, prixMax, forSale, forRent, pageable);
        return ResponseEntity.ok(biens);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<BienDetailDTO> getBienById(@PathVariable Long id) {
        BienDetailDTO bien = bienService.findById(id);
        return ResponseEntity.ok(bien);
    }
    
    @PostMapping
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    public ResponseEntity<BienDTO> createBien(@Valid @RequestBody CreateBienRequest request) {
        BienDTO created = bienService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
}
