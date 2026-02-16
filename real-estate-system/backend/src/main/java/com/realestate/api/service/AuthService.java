package com.realestate.api.service;

import com.realestate.api.dto.AgentDTO;
import com.realestate.api.dto.AuthenticationResponse;
import com.realestate.api.dto.LoginRequest;
import com.realestate.api.entity.Agent;
import com.realestate.api.security.AgentUserDetailsService;
import com.realestate.api.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final AgentUserDetailsService userDetailsService;
    private final JwtUtil jwtUtil;

    public AuthenticationResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        Agent agent = userDetailsService.loadAgentByUsername(request.getEmail());
        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());

        Map<String, Object> claims = new HashMap<>();
        claims.put("agenceId", agent.getAgence().getId());
        claims.put("role", agent.getRole().name());
        claims.put("agentId", agent.getId());

        String token = jwtUtil.generateToken(userDetails, claims);

        AgentDTO agentDTO = convertToDTO(agent);
        return new AuthenticationResponse(token, agentDTO);
    }

    private AgentDTO convertToDTO(Agent agent) {
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
        return dto;
    }
}
