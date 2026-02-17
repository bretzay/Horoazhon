package com.realestate.api.controller;

import com.realestate.api.entity.Agence;
import com.realestate.api.entity.Compte;
import com.realestate.api.entity.Personne;
import com.realestate.api.repository.AgenceRepository;
import com.realestate.api.repository.CompteRepository;
import com.realestate.api.repository.PersonneRepository;
import com.realestate.api.security.SecurityUtils;
import com.realestate.api.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final CompteRepository compteRepository;
    private final PersonneRepository personneRepository;
    private final AgenceRepository agenceRepository;
    private final SecurityUtils securityUtils;
    private final EmailService emailService;

    @GetMapping
    public ResponseEntity<Page<Map<String, Object>>> listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Long agenceId = securityUtils.getCurrentAgenceId();
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        Page<Compte> comptes = agenceId != null
                ? compteRepository.findByAgenceId(agenceId, pageable)
                : compteRepository.findAll(pageable);

        Page<Map<String, Object>> result = comptes.map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("email", c.getEmail());
            map.put("nom", c.getNom());
            map.put("prenom", c.getPrenom());
            map.put("role", c.getRole().name());
            map.put("actif", c.getActif());
            map.put("activated", c.isActivated());
            map.put("dateCreation", c.getDateCreation());
            return map;
        });

        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createUser(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String nom = request.get("nom");
        String prenom = request.get("prenom");
        String role = request.get("role");
        String dateNaisStr = request.get("dateNais");

        if (compteRepository.existsByEmail(email)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email already exists"));
        }

        Compte currentCompte = securityUtils.getCurrentCompteOrThrow();

        // Role hierarchy: can only create roles strictly below your own
        Compte.Role newRole = Compte.Role.valueOf(role);
        if (newRole.ordinal() >= currentCompte.getRole().ordinal()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Vous ne pouvez pas creer un utilisateur avec un role egal ou superieur au votre."));
        }

        // Create Personne first — every Compte must link to a Personne
        Personne personne = new Personne();
        personne.setNom(nom);
        personne.setPrenom(prenom);
        personne.setDateNais(dateNaisStr != null ? LocalDate.parse(dateNaisStr) : LocalDate.of(1990, 1, 1));
        personneRepository.save(personne);

        // Determine agency: SUPER_ADMIN can assign to any agency via agenceId param
        Agence agence;
        if (currentCompte.isSuperAdmin()) {
            String agenceIdStr = request.get("agenceId");
            if (agenceIdStr == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "agenceId is required for SUPER_ADMIN"));
            }
            agence = agenceRepository.findById(Long.valueOf(agenceIdStr))
                    .orElseThrow(() -> new RuntimeException("Agence not found"));
        } else {
            agence = currentCompte.getAgence();
        }

        // Create account with activation token (no password)
        String token = UUID.randomUUID().toString();

        Compte compte = new Compte();
        compte.setEmail(email);
        compte.setRole(Compte.Role.valueOf(role));
        compte.setAgence(agence);
        compte.setPersonne(personne);
        compte.setActif(true);
        compte.setTokenActivation(token);
        compte.setTokenExpiration(LocalDateTime.now().plusDays(7));

        compteRepository.save(compte);

        // Send activation email if frontend provided a base URL
        String activationBaseUrl = request.get("activationBaseUrl");
        if (activationBaseUrl != null && !activationBaseUrl.isBlank()) {
            String activationUrl = activationBaseUrl + "/activate?token=" + token;
            emailService.sendActivationEmail(email, prenom, activationUrl);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", compte.getId());
        result.put("email", compte.getEmail());
        result.put("nom", compte.getNom());
        result.put("prenom", compte.getPrenom());
        result.put("role", compte.getRole().name());
        result.put("activationToken", token);
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deactivateUser(@PathVariable Long id) {
        Compte currentCompte = securityUtils.getCurrentCompteOrThrow();

        Compte compte = compteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Agency check: skip for SUPER_ADMIN, enforce for others
        if (!currentCompte.isSuperAdmin()) {
            if (compte.getAgence() == null || currentCompte.getAgence() == null
                    || !compte.getAgence().getId().equals(currentCompte.getAgence().getId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }

        // Cannot deactivate someone with equal or higher role
        if (compte.getRole().ordinal() >= currentCompte.getRole().ordinal()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        compte.setActif(false);
        compteRepository.save(compte);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/reactivate")
    public ResponseEntity<Void> reactivateUser(@PathVariable Long id) {
        Compte currentCompte = securityUtils.getCurrentCompteOrThrow();

        Compte compte = compteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Agency check: skip for SUPER_ADMIN, enforce for others
        if (!currentCompte.isSuperAdmin()) {
            if (compte.getAgence() == null || currentCompte.getAgence() == null
                    || !compte.getAgence().getId().equals(currentCompte.getAgence().getId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }

        // Cannot reactivate someone with equal or higher role
        if (compte.getRole().ordinal() >= currentCompte.getRole().ordinal()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        compte.setActif(true);
        compteRepository.save(compte);
        return ResponseEntity.noContent().build();
    }
}
