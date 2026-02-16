package com.realestate.api.controller;

import com.realestate.api.dto.AgentDTO;
import com.realestate.api.dto.CreateAgentRequest;
import com.realestate.api.security.AgentUserDetailsService;
import com.realestate.api.service.AgentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
public class AgentController {

    private final AgentService agentService;
    private final AgentUserDetailsService userDetailsService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN_AGENCY')")
    public ResponseEntity<Page<AgentDTO>> getAgentsByAgence(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        var agent = userDetailsService.loadAgentByUsername(authentication.getName());
        Pageable pageable = PageRequest.of(page, size);
        Page<AgentDTO> agents = agentService.findByAgence(agent.getAgence().getId(), pageable);
        return ResponseEntity.ok(agents);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AgentDTO> getAgent(@PathVariable Long id) {
        AgentDTO agent = agentService.findById(id);
        return ResponseEntity.ok(agent);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN_AGENCY')")
    public ResponseEntity<AgentDTO> createAgent(
            @Valid @RequestBody CreateAgentRequest request,
            Authentication authentication
    ) {
        var creator = userDetailsService.loadAgentByUsername(authentication.getName());
        AgentDTO created = agentService.create(request, creator.getAgence().getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN_AGENCY')")
    public ResponseEntity<Void> deactivateAgent(
            @PathVariable Long id,
            Authentication authentication
    ) {
        var agent = userDetailsService.loadAgentByUsername(authentication.getName());
        agentService.deactivate(id, agent.getAgence().getId());
        return ResponseEntity.noContent().build();
    }
}
