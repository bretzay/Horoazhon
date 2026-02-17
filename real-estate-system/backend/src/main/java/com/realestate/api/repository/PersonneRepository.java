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

    // Find by name (partial match, accent-insensitive via SQL Server collation)
    @Query(value = "SELECT * FROM Personne WHERE " +
           "nom COLLATE Latin1_General_CI_AI LIKE '%' + :q + '%' " +
           "OR prenom COLLATE Latin1_General_CI_AI LIKE '%' + :q + '%'",
           nativeQuery = true)
    List<Personne> searchByNameIgnoreAccents(@Param("q") String q);

    // Find persons who own properties
    @Query("SELECT DISTINCT p FROM Personne p JOIN p.biens")
    List<Personne> findProprietaires();

    // Find persons with contracts
    @Query("SELECT DISTINCT p FROM Personne p JOIN p.contrats")
    List<Personne> findPersonsWithContracts();

    // Agency-filtered queries using Compte table (personne linked to compte with agence_id)
    @Query("SELECT DISTINCT p FROM Personne p " +
           "JOIN Compte c ON c.personne.id = p.id " +
           "WHERE c.agence.id = :agenceId")
    Page<Personne> findByAgence(@Param("agenceId") Long agenceId, Pageable pageable);

    @Query(value = "SELECT DISTINCT p.* FROM Personne p " +
           "JOIN Compte c ON c.personne_id = p.id " +
           "WHERE c.agence_id = :agenceId " +
           "AND (p.nom COLLATE Latin1_General_CI_AI LIKE '%' + :searchTerm + '%' " +
           "OR p.prenom COLLATE Latin1_General_CI_AI LIKE '%' + :searchTerm + '%')",
           nativeQuery = true)
    List<Personne> searchByAgence(@Param("agenceId") Long agenceId,
                                   @Param("searchTerm") String searchTerm);

    @Query("SELECT DISTINCT p FROM Personne p " +
           "JOIN Compte c ON c.personne.id = p.id " +
           "JOIN Posseder pos ON pos.personne.id = p.id " +
           "WHERE c.agence.id = :agenceId")
    List<Personne> findProprietairesByAgence(@Param("agenceId") Long agenceId);
}
