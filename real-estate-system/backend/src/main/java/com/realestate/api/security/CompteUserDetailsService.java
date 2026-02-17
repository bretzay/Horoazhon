package com.realestate.api.security;

import com.realestate.api.entity.Compte;
import com.realestate.api.repository.CompteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CompteUserDetailsService implements UserDetailsService {

    private final CompteRepository compteRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Compte compte = compteRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Account not found: " + email));

        if (!compte.getActif()) {
            throw new UsernameNotFoundException("Account is inactive");
        }

        if (!compte.isActivated()) {
            throw new UsernameNotFoundException("Account not yet activated");
        }

        return User.builder()
                .username(compte.getEmail())
                .password(compte.getPassword())
                .authorities(List.of(new SimpleGrantedAuthority("ROLE_" + compte.getRole().name())))
                .build();
    }

    public Compte loadCompteByEmail(String email) {
        return compteRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Account not found: " + email));
    }
}
