package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PersonneRepository extends JpaRepository<Personne, Long> {
    
    // Find by name
    List<Personne> findByNomAndPrenom(String nom, String prenom);
    
    // Find by name (partial match)
    List<Personne> findByNomContainingIgnoreCaseOrPrenomContainingIgnoreCase(
        String nom, 
        String prenom
    );
    
    // Find persons who own properties
    @Query("SELECT DISTINCT p FROM Personne p JOIN p.biens")
    List<Personne> findProprietaires();
    
    // Find persons with contracts
    @Query("SELECT DISTINCT p FROM Personne p JOIN p.contrats")
    List<Personne> findPersonsWithContracts();
}