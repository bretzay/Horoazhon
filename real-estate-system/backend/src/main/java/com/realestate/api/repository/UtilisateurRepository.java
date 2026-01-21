package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UtilisateurRepository extends JpaRepository<Utilisateur, Long> {
    
    // Find by login
    Optional<Utilisateur> findByLogin(String login);
    
    // Find by email
    Optional<Utilisateur> findByEmail(String email);
    
    // Check if login exists
    boolean existsByLogin(String login);
    
    // Check if email exists
    boolean existsByEmail(String email);
    
    // Find by access level
    List<Utilisateur> findByNiveauAcces(Utilisateur.NiveauAcces niveauAcces);
    
    // Find by personne
    @Query("SELECT u FROM Utilisateur u JOIN u.personnes o WHERE o.personne.id = :personneId")
    Optional<Utilisateur> findByPersonneId(@Param("personneId") Long personneId);
}