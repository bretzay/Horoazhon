package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OuvrirRepository extends JpaRepository<Ouvrir, Ouvrir.OuvrirId> {
    
    // Find by personne
    List<Ouvrir> findByPersonneId(Long personneId);
    
    // Find by utilisateur
    Optional<Ouvrir> findByUtilisateurId(Long utilisateurId);
    
    // Check if person has user account
    boolean existsByPersonneId(Long personneId);
}
