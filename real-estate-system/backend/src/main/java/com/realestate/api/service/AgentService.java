package com.realestate.api.service;

import com.realestate.api.dto.AgentDTO;
import com.realestate.api.dto.CreateAgentRequest;
import com.realestate.api.entity.Agence;
import com.realestate.api.entity.Agent;
import com.realestate.api.repository.AgenceRepository;
import com.realestate.api.repository.AgentRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AgentService {

    private final AgentRepository agentRepository;
    private final AgenceRepository agenceRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public Page<AgentDTO> findByAgence(Long agenceId, Pageable pageable) {
        return agentRepository.findByAgenceId(agenceId, pageable)
                .map(this::convertToDTO);
    }

    @Transactional(readOnly = true)
    public AgentDTO findById(Long id) {
        Agent agent = agentRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Agent not found with id: " + id));
        return convertToDTO(agent);
    }

    public AgentDTO create(CreateAgentRequest request, Long creatorAgenceId) {
        // Verify the creator is creating an agent for their own agency
        if (!request.getAgenceId().equals(creatorAgenceId)) {
            throw new IllegalArgumentException("You can only create agents for your own agency");
        }

        if (agentRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        Agence agence = agenceRepository.findById(request.getAgenceId())
                .orElseThrow(() -> new EntityNotFoundException("Agence not found"));

        Agent agent = new Agent();
        agent.setEmail(request.getEmail());
        agent.setPassword(passwordEncoder.encode(request.getPassword()));
        agent.setNom(request.getNom());
        agent.setPrenom(request.getPrenom());
        agent.setAgence(agence);
        agent.setRole(Agent.Role.valueOf(request.getRole()));
        agent.setActif(true);

        Agent saved = agentRepository.save(agent);
        return convertToDTO(saved);
    }

    public void deactivate(Long id, Long agenceId) {
        Agent agent = agentRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Agent not found"));

        if (!agent.getAgence().getId().equals(agenceId)) {
            throw new IllegalArgumentException("You can only deactivate agents from your own agency");
        }

        agent.setActif(false);
        agentRepository.save(agent);
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
