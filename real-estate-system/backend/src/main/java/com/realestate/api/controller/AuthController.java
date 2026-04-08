package com.realestate.api.controller;

import com.realestate.api.dto.*;
import com.realestate.api.entity.Compte;
import com.realestate.api.security.CompteUserDetailsService;
import com.realestate.api.security.SecurityUtils;
import com.realestate.api.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final CompteUserDetailsService userDetailsService;
    private final SecurityUtils securityUtils;

    @Value("${app.frontend.base-url:https://localhost:8001}")
    private String frontendBaseUrl;

    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthenticationResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/activate")
    public ResponseEntity<Map<String, String>> activateAccount(@Valid @RequestBody ActivateAccountRequest request) {
        authService.activateAccount(request);
        return ResponseEntity.ok(Map.of("message", "Account activated successfully"));
    }

    @GetMapping("/activation-status")
    public ResponseEntity<Map<String, Object>> checkActivationToken(@RequestParam String token) {
        boolean valid = authService.isTokenValid(token);
        return ResponseEntity.ok(Map.of("valid", valid));
    }

    /**
     * Resolves the frontend base URL by replacing the configured hostname with the
     * actual host from the incoming request. This ensures links work in production
     * where the server is accessed by IP, not localhost.
     */
    private String resolveFrontendBaseUrl(HttpServletRequest request) {
        try {
            URI configured = URI.create(frontendBaseUrl);
            String requestHost = request.getServerName();
            URI resolved = new URI(configured.getScheme(), null, requestHost,
                    configured.getPort(), configured.getPath(), null, null);
            return resolved.toString();
        } catch (Exception e) {
            return frontendBaseUrl;
        }
    }

    @PostMapping("/invite-client")
    public ResponseEntity<Map<String, String>> inviteClient(@Valid @RequestBody InviteClientRequest request, HttpServletRequest httpRequest) {
        // Manual role check: endpoint is under /api/auth/** (permitAll) so @PreAuthorize won't work
        if (!securityUtils.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("error", "Authentication required"));
        }
        Compte currentCompte = securityUtils.getCurrentCompteOrThrow();
        if (!currentCompte.isSuperAdmin() && currentCompte.getRole() != Compte.Role.ADMIN_AGENCY) {
            return ResponseEntity.status(403).body(Map.of("error", "Seuls les administrateurs peuvent inviter des clients"));
        }

        Long agenceId;
        if (currentCompte.isSuperAdmin()) {
            if (request.getAgenceId() == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "agenceId is required for SUPER_ADMIN"));
            }
            agenceId = request.getAgenceId();
        } else {
            agenceId = currentCompte.getAgence().getId();
        }

        String token = authService.createClientAccount(request.getPersonneId(), request.getEmail(), agenceId);

        String activationUrl = resolveFrontendBaseUrl(httpRequest) + "/activate?token=" + token;

        return ResponseEntity.ok(Map.of(
                "message", "Invitation envoyee",
                "activationUrl", activationUrl
        ));
    }

    // ========== Password Reset ==========

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, String>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request, HttpServletRequest httpRequest) {
        authService.requestPasswordReset(request.getEmail(), resolveFrontendBaseUrl(httpRequest));
        // Always return success to avoid revealing which emails exist
        return ResponseEntity.ok(Map.of("message", "Si un compte existe avec cet email, un lien de reinitialisation a ete envoye."));
    }

    @GetMapping("/reset-status")
    public ResponseEntity<Map<String, Object>> checkResetToken(@RequestParam String token) {
        boolean valid = authService.isResetTokenValid(token);
        return ResponseEntity.ok(Map.of("valid", valid));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(Map.of("message", "Mot de passe reinitialise avec succes."));
    }

    @PostMapping("/change-password")
    public ResponseEntity<Map<String, String>> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        if (!securityUtils.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("error", "Authentication required"));
        }
        Compte compte = securityUtils.getCurrentCompteOrThrow();
        authService.changePassword(compte, request);
        return ResponseEntity.ok(Map.of("message", "Mot de passe modifie avec succes."));
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
        result.put("agenceLogo", compte.getAgence() != null ? compte.getAgence().getLogo() : null);
        result.put("personneId", compte.getPersonne() != null ? compte.getPersonne().getId() : null);

        return ResponseEntity.ok(result);
    }
}
