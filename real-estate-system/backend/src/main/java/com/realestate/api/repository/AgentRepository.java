package com.realestate.api.repository;

import com.realestate.api.entity.Agent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AgentRepository extends JpaRepository<Agent, Long> {

    Optional<Agent> findByEmail(String email);

    boolean existsByEmail(String email);

    Page<Agent> findByAgenceId(Long agenceId, Pageable pageable);

    Page<Agent> findByAgenceIdAndActif(Long agenceId, Boolean actif, Pageable pageable);
}
