package com.realestate.api.repository;

import com.realestate.api.entity.Compte;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CompteRepository extends JpaRepository<Compte, Long> {

    Optional<Compte> findByEmail(String email);

    Optional<Compte> findByTokenActivation(String token);

    Optional<Compte> findByPersonneId(Long personneId);

    boolean existsByEmail(String email);

    boolean existsByPersonneId(Long personneId);

    Page<Compte> findByAgenceId(Long agenceId, Pageable pageable);

    List<Compte> findByAgenceIdAndRole(Long agenceId, Compte.Role role);

    Page<Compte> findByAgenceIdAndRole(Long agenceId, Compte.Role role, Pageable pageable);
}
