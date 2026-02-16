package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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

    // Agency-filtered queries using AgencePersonne linking table
    @Query("SELECT p FROM Personne p " +
           "JOIN AgencePersonne ap ON ap.personne.id = p.id " +
           "WHERE ap.agence.id = :agenceId")
    Page<Personne> findByAgence(@Param("agenceId") Long agenceId, Pageable pageable);

    @Query("SELECT p FROM Personne p " +
           "JOIN AgencePersonne ap ON ap.personne.id = p.id " +
           "WHERE ap.agence.id = :agenceId " +
           "AND (LOWER(p.nom) LIKE LOWER(CONCAT('%', :searchTerm, '%')) " +
           "OR LOWER(p.prenom) LIKE LOWER(CONCAT('%', :searchTerm, '%')))")
    List<Personne> searchByAgence(@Param("agenceId") Long agenceId,
                                   @Param("searchTerm") String searchTerm);

    @Query("SELECT DISTINCT p FROM Personne p " +
           "JOIN AgencePersonne ap ON ap.personne.id = p.id " +
           "JOIN Posseder pos ON pos.personne.id = p.id " +
           "WHERE ap.agence.id = :agenceId")
    List<Personne> findProprietairesByAgence(@Param("agenceId") Long agenceId);
}