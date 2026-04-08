package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.Agence;
import com.realestate.api.entity.Compte;
import com.realestate.api.entity.Personne;
import com.realestate.api.repository.AgenceRepository;
import com.realestate.api.repository.CompteRepository;
import com.realestate.api.repository.PersonneRepository;
import com.realestate.api.security.CompteUserDetailsService;
import com.realestate.api.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final CompteUserDetailsService userDetailsService;
    private final CompteRepository compteRepository;
    private final PersonneRepository personneRepository;
    private final AgenceRepository agenceRepository;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    public AuthenticationResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        Compte compte = userDetailsService.loadCompteByEmail(request.getEmail());
        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());

        Map<String, Object> claims = new HashMap<>();
        claims.put("role", compte.getRole().name());
        claims.put("agenceId", compte.getAgence() != null ? compte.getAgence().getId() : null);
        claims.put("personneId", compte.getPersonne() != null ? compte.getPersonne().getId() : null);

        String token = jwtUtil.generateToken(userDetails, claims);

        AuthenticationResponse response = new AuthenticationResponse();
        response.setToken(token);
        response.setRole(compte.getRole().name());
        response.setNom(compte.getNom());
        response.setPrenom(compte.getPrenom());
        response.setAgenceId(compte.getAgence() != null ? compte.getAgence().getId() : null);
        response.setAgenceNom(compte.getAgence() != null ? compte.getAgence().getNom() : null);
        response.setAgenceLogo(compte.getAgence() != null ? compte.getAgence().getLogo() : null);
        response.setPersonneId(compte.getPersonne() != null ? compte.getPersonne().getId() : null);
        return response;
    }

    public String createClientAccount(Long personneId, String email, Long agenceId) {
        if (compteRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("An account with this email already exists");
        }
        if (compteRepository.existsByPersonneId(personneId)) {
            throw new IllegalArgumentException("This person already has an account");
        }

        Personne personne = personneRepository.findById(personneId)
                .orElseThrow(() -> new IllegalArgumentException("Personne not found with id: " + personneId));

        Agence agence = agenceRepository.findById(agenceId)
                .orElseThrow(() -> new IllegalArgumentException("Agence not found with id: " + agenceId));

        Compte compte = new Compte();
        compte.setEmail(email);
        compte.setRole(Compte.Role.CLIENT);
        compte.setAgence(agence);
        compte.setPersonne(personne);
        compte.setActif(true);

        String token = UUID.randomUUID().toString();
        compte.setTokenActivation(token);
        compte.setTokenExpiration(LocalDateTime.now().plusDays(7));

        compteRepository.save(compte);
        return token;
    }

    public void activateAccount(ActivateAccountRequest request) {
        Compte compte = compteRepository.findByTokenActivation(request.getToken())
                .orElseThrow(() -> new IllegalArgumentException("Invalid activation token"));

        if (!compte.isTokenValid()) {
            throw new IllegalArgumentException("Activation token has expired");
        }

        compte.setPassword(passwordEncoder.encode(request.getPassword()));
        compte.setTokenActivation(null);
        compte.setTokenExpiration(null);
        compteRepository.save(compte);
    }

    public boolean isTokenValid(String token) {
        return compteRepository.findByTokenActivation(token)
                .map(Compte::isTokenValid)
                .orElse(false);
    }

    // ========== Password Reset ==========

    public void requestPasswordReset(String email, String resolvedFrontendBaseUrl) {
        Compte compte = compteRepository.findByEmail(email)
                .orElse(null);

        // Silently succeed even if email doesn't exist (security: don't reveal valid emails)
        if (compte == null || !compte.isActivated()) {
            return;
        }

        String token = UUID.randomUUID().toString();
        compte.setTokenReset(token);
        compte.setTokenResetExpiration(LocalDateTime.now().plusHours(1));
        compteRepository.save(compte);

        // TODO: Send email with reset link containing this token
        String resetUrl = resolvedFrontendBaseUrl + "/reset-password?token=" + token;
        log.debug("Password reset link for {}: {}", email, resetUrl);
    }

    public boolean isResetTokenValid(String token) {
        return compteRepository.findByTokenReset(token)
                .map(Compte::isResetTokenValid)
                .orElse(false);
    }

    public void changePassword(Compte compte, ChangePasswordRequest request) {
        if (!passwordEncoder.matches(request.getCurrentPassword(), compte.getPassword())) {
            throw new IllegalArgumentException("Le mot de passe actuel est incorrect");
        }
        compte.setPassword(passwordEncoder.encode(request.getNewPassword()));
        compteRepository.save(compte);
    }

    public void resetPassword(ResetPasswordRequest request) {
        Compte compte = compteRepository.findByTokenReset(request.getToken())
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

        if (!compte.isResetTokenValid()) {
            throw new IllegalArgumentException("Reset token has expired");
        }

        compte.setPassword(passwordEncoder.encode(request.getPassword()));
        // Invalidate the token (single-use)
        compte.setTokenReset(null);
        compte.setTokenResetExpiration(null);
        compteRepository.save(compte);
    }
}
