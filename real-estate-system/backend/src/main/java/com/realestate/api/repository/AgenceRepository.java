package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AgenceRepository extends JpaRepository<Agence, Long> {
    
    // Find by SIRET
    Optional<Agence> findBySiret(String siret);
    
    // Find by name
    List<Agence> findByNomContainingIgnoreCase(String nom);
    
    // Find by city
    List<Agence> findByVille(String ville);
}