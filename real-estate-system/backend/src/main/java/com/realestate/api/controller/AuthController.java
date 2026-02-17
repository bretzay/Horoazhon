package com.realestate.api.controller;

import com.realestate.api.dto.ActivateAccountRequest;
import com.realestate.api.dto.AuthenticationResponse;
import com.realestate.api.dto.LoginRequest;
import com.realestate.api.entity.Compte;
import com.realestate.api.security.CompteUserDetailsService;
import com.realestate.api.security.SecurityUtils;
import com.realestate.api.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final CompteUserDetailsService userDetailsService;
    private final SecurityUtils securityUtils;

    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthenticationResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/activate")
    public ResponseEntity<Map<String, String>> activateAccount(@RequestBody ActivateAccountRequest request) {
        authService.activateAccount(request);
        return ResponseEntity.ok(Map.of("message", "Account activated successfully"));
    }

    @GetMapping("/activation-status")
    public ResponseEntity<Map<String, Object>> checkActivationToken(@RequestParam String token) {
        boolean valid = authService.isTokenValid(token);
        return ResponseEntity.ok(Map.of("valid", valid));
    }

    @PostMapping("/invite-client")
    public ResponseEntity<Map<String, String>> inviteClient(@RequestBody Map<String, Object> request) {
        Long personneId = Long.valueOf(request.get("personneId").toString());
        String email = request.get("email").toString();

        Compte currentCompte = securityUtils.getCurrentCompteOrThrow();
        Long agenceId;
        if (currentCompte.isSuperAdmin()) {
            // SUPER_ADMIN must provide agenceId in request
            Object reqAgenceId = request.get("agenceId");
            if (reqAgenceId == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "agenceId is required for SUPER_ADMIN"));
            }
            agenceId = Long.valueOf(reqAgenceId.toString());
        } else {
            agenceId = currentCompte.getAgence().getId();
        }

        String token = authService.createClientAccount(personneId, email, agenceId);

        String activationUrl = "http://localhost:8001/activate?token=" + token;

        return ResponseEntity.ok(Map.of(
                "message", "Invitation envoyee",
                "activationUrl", activationUrl
        ));
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }

        Compte compte = userDetailsService.loadCompteByEmail(authentication.getName());

        Map<String, Object> result = new HashMap<>();
        result.put("id", compte.getId());
        result.put("email", compte.getEmail());
        result.put("nom", compte.getNom());
        result.put("prenom", compte.getPrenom());
        result.put("role", compte.getRole().name());
        result.put("agenceId", compte.getAgence() != null ? compte.getAgence().getId() : null);
        result.put("agenceNom", compte.getAgence() != null ? compte.getAgence().getNom() : null);
        result.put("personneId", compte.getPersonne().getId());

        return ResponseEntity.ok(result);
    }
}
