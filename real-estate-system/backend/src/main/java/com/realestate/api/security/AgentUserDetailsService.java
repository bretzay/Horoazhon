package com.realestate.api.security;

import com.realestate.api.entity.Agent;
import com.realestate.api.repository.AgentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
@RequiredArgsConstructor
public class AgentUserDetailsService implements UserDetailsService {

    private final AgentRepository agentRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Agent agent = agentRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Agent not found with email: " + email));

        if (!agent.getActif()) {
            throw new UsernameNotFoundException("Agent account is inactive");
        }

        return User.builder()
                .username(agent.getEmail())
                .password(agent.getPassword())
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + agent.getRole().name())))
                .build();
    }

    public Agent loadAgentByUsername(String email) {
        return agentRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Agent not found with email: " + email));
    }
}
