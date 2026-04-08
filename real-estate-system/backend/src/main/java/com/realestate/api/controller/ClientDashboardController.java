package com.realestate.api.controller;

import com.realestate.api.dto.BienDTO;
import com.realestate.api.dto.ClientDashboardDTO;
import com.realestate.api.dto.ContratDTO;
import com.realestate.api.dto.CreatePersonneRequest;
import com.realestate.api.dto.PersonneDTO;
import com.realestate.api.entity.Compte;
import com.realestate.api.security.CompteUserDetailsService;
import com.realestate.api.service.ClientDashboardService;
import com.realestate.api.service.PersonneService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/client")
@RequiredArgsConstructor
@PreAuthorize("hasRole('CLIENT')")
public class ClientDashboardController {

    private final ClientDashboardService dashboardService;
    private final CompteUserDetailsService userDetailsService;
    private final PersonneService personneService;

    @GetMapping("/dashboard")
    public ResponseEntity<ClientDashboardDTO> getDashboard(Authentication authentication) {
        Long personneId = getPersonneId(authentication);
        ClientDashboardDTO dashboard = dashboardService.getDashboard(personneId);
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/contrats")
    public ResponseEntity<Page<ContratDTO>> getContracts(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Long personneId = getPersonneId(authentication);
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
        Page<ContratDTO> contracts = dashboardService.getClientContracts(personneId, pageable);
        return ResponseEntity.ok(contracts);
    }

    @GetMapping("/biens")
    public ResponseEntity<Page<BienDTO>> getProperties(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Long personneId = getPersonneId(authentication);
        Pageable pageable = PageRequest.of(page, size);
        Page<BienDTO> properties = dashboardService.getClientProperties(personneId, pageable);
        return ResponseEntity.ok(properties);
    }

    @GetMapping("/profile")
    public ResponseEntity<PersonneDTO> getProfile(Authentication authentication) {
        Long personneId = getPersonneId(authentication);
        return ResponseEntity.ok(personneService.findById(personneId));
    }

    @PutMapping("/profile")
    public ResponseEntity<PersonneDTO> updateProfile(
            Authentication authentication,
            @Valid @RequestBody CreatePersonneRequest request
    ) {
        Long personneId = getPersonneId(authentication);
        return ResponseEntity.ok(personneService.update(personneId, request));
    }

    private Long getPersonneId(Authentication authentication) {
        Compte compte = userDetailsService.loadCompteByEmail(authentication.getName());
        if (compte.getPersonne() == null) {
            throw new IllegalStateException("No person linked to this account");
        }
        return compte.getPersonne().getId();
    }
}
