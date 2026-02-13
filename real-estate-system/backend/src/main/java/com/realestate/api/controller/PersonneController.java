package com.realestate.api.controller;

import com.realestate.api.dto.CreatePersonneRequest;
import com.realestate.api.dto.PersonneDTO;
import com.realestate.api.service.PersonneService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/personnes")
@RequiredArgsConstructor
public class PersonneController {

    private final PersonneService personneService;

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
}