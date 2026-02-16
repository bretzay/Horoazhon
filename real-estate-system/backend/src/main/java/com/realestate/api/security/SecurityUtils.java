package com.realestate.api.security;

import com.realestate.api.entity.Agent;
import com.realestate.api.repository.AgentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class SecurityUtils {

    private final AgentRepository agentRepository;

    public Optional<Agent> getCurrentAgent() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return Optional.empty();
        }

        String email = authentication.getName();
        return agentRepository.findByEmail(email);
    }

    public Agent getCurrentAgentOrThrow() {
        return getCurrentAgent()
                .orElseThrow(() -> new SecurityException("No authenticated agent found"));
    }

    public Long getCurrentAgenceId() {
        return getCurrentAgentOrThrow().getAgence().getId();
    }

    public boolean isAuthenticated() {
        return getCurrentAgent().isPresent();
    }
}
