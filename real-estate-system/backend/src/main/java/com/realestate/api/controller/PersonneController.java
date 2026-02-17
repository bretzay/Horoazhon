package com.realestate.api.controller;

import com.realestate.api.dto.*;
import com.realestate.api.entity.Compte;
import com.realestate.api.repository.CompteRepository;
import com.realestate.api.service.PersonneService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/personnes")
@RequiredArgsConstructor
public class PersonneController {

    private final PersonneService personneService;
    private final CompteRepository compteRepository;

    @GetMapping
    public ResponseEntity<List<PersonneDTO>> getAllPersonnes() {
        return ResponseEntity.ok(personneService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PersonneDTO> getPersonneById(@PathVariable Long id) {
        return ResponseEntity.ok(personneService.findById(id));
    }

    @GetMapping("/search")
    public ResponseEntity<List<PersonneDTO>> searchPersonnes(@RequestParam String q) {
        return ResponseEntity.ok(personneService.search(q));
    }

    @PostMapping
    public ResponseEntity<PersonneDTO> createPersonne(@Valid @RequestBody CreatePersonneRequest request) {
        PersonneDTO created = personneService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PersonneDTO> updatePersonne(@PathVariable Long id, @Valid @RequestBody CreatePersonneRequest request) {
        return ResponseEntity.ok(personneService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePersonne(@PathVariable Long id) {
        personneService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/account-status")
    public ResponseEntity<Map<String, Object>> getAccountStatus(@PathVariable Long id) {
        return compteRepository.findByPersonneId(id)
                .map(compte -> {
                    String status;
                    if (compte.isActivated()) {
                        status = "ACTIVE";
                    } else if (compte.isTokenValid()) {
                        status = "PENDING";
                    } else {
                        status = "EXPIRED";
                    }
                    return ResponseEntity.ok(Map.<String, Object>of(
                            "hasAccount", true,
                            "status", status,
                            "email", compte.getEmail()
                    ));
                })
                .orElse(ResponseEntity.ok(Map.of("hasAccount", false)));
    }

    @GetMapping("/{id}/biens")
    public ResponseEntity<List<BienDTO>> getPersonneBiens(@PathVariable Long id) {
        return ResponseEntity.ok(personneService.findBiensByPersonne(id));
    }

    @GetMapping("/{id}/contrats")
    public ResponseEntity<List<ContratDTO>> getPersonneContrats(@PathVariable Long id) {
        return ResponseEntity.ok(personneService.findContratsByPersonne(id));
    }
}