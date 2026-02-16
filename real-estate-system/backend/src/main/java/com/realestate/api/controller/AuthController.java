package com.realestate.api.controller;

import com.realestate.api.dto.AgentDTO;
import com.realestate.api.dto.AuthenticationResponse;
import com.realestate.api.dto.LoginRequest;
import com.realestate.api.security.AgentUserDetailsService;
import com.realestate.api.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final AgentUserDetailsService userDetailsService;

    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthenticationResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<AgentDTO> getCurrentAgent(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }

        String email = authentication.getName();
        var agent = userDetailsService.loadAgentByUsername(email);

        AgentDTO dto = new AgentDTO();
        dto.setId(agent.getId());
        dto.setEmail(agent.getEmail());
        dto.setNom(agent.getNom());
        dto.setPrenom(agent.getPrenom());
        dto.setRole(agent.getRole().name());
        dto.setActif(agent.getActif());
        dto.setDateCreation(agent.getDateCreation());
        if (agent.getAgence() != null) {
            dto.setAgenceId(agent.getAgence().getId());
            dto.setAgenceNom(agent.getAgence().getNom());
        }

        return ResponseEntity.ok(dto);
    }
}
