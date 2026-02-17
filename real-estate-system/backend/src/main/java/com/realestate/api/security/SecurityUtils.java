package com.realestate.api.security;

import com.realestate.api.entity.Compte;
import com.realestate.api.repository.CompteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class SecurityUtils {

    private final CompteRepository compteRepository;

    public Optional<Compte> getCurrentCompte() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return Optional.empty();
        }

        String email = authentication.getName();
        return compteRepository.findByEmail(email);
    }

    public Compte getCurrentCompteOrThrow() {
        return getCurrentCompte()
                .orElseThrow(() -> new SecurityException("No authenticated user found"));
    }

    /**
     * Returns the current user's agenceId, or null if SUPER_ADMIN (no agency).
     */
    public Long getCurrentAgenceId() {
        Compte compte = getCurrentCompteOrThrow();
        return compte.getAgence() != null ? compte.getAgence().getId() : null;
    }

    public boolean isAuthenticated() {
        return getCurrentCompte().isPresent();
    }
}
