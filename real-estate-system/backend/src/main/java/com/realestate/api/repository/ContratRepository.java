package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ContratRepository extends JpaRepository<Contrat, Long> {

    @Query("SELECT c FROM Contrat c LEFT JOIN FETCH c.cosigners cs LEFT JOIN FETCH cs.personne LEFT JOIN FETCH c.location l LEFT JOIN FETCH l.bien LEFT JOIN FETCH c.achat a LEFT JOIN FETCH a.bien WHERE c.id = :id")
    Optional<Contrat> findByIdWithDetails(@Param("id") Long id);
    
    // Find contracts by location
    List<Contrat> findByLocationId(Long locationId);
    
    // Find contracts by achat
    List<Contrat> findByAchatId(Long achatId);
    
    // Find contracts by status
    Page<Contrat> findByStatut(Contrat.StatutContrat statut, Pageable pageable);
    
    // Find contracts for a specific person (as co-signer)
    @Query("SELECT c FROM Contrat c JOIN c.cosigners cs WHERE cs.personne.id = :personneId")
    Page<Contrat> findByPersonneId(@Param("personneId") Long personneId, Pageable pageable);
    
    // Find rental contracts
    @Query("SELECT c FROM Contrat c WHERE c.location IS NOT NULL")
    Page<Contrat> findRentalContracts(Pageable pageable);
    
    // Find purchase contracts
    @Query("SELECT c FROM Contrat c WHERE c.achat IS NOT NULL")
    Page<Contrat> findPurchaseContracts(Pageable pageable);

    // Agency-filtered queries
    @Query("SELECT c FROM Contrat c " +
           "LEFT JOIN c.location l " +
           "LEFT JOIN c.achat a " +
           "WHERE (l.bien.agence.id = :agenceId OR a.bien.agence.id = :agenceId)")
    Page<Contrat> findByAgence(@Param("agenceId") Long agenceId, Pageable pageable);

    @Query("SELECT c FROM Contrat c " +
           "LEFT JOIN c.location l " +
           "LEFT JOIN c.achat a " +
           "WHERE (l.bien.agence.id = :agenceId OR a.bien.agence.id = :agenceId) " +
           "AND c.statut = :statut")
    Page<Contrat> findByAgenceAndStatut(@Param("agenceId") Long agenceId,
                                         @Param("statut") Contrat.StatutContrat statut,
                                         Pageable pageable);

    @Query("SELECT c FROM Contrat c " +
           "JOIN c.cosigners cs " +
           "LEFT JOIN c.location l " +
           "LEFT JOIN c.achat a " +
           "WHERE cs.personne.id = :personneId " +
           "AND (l.bien.agence.id = :agenceId OR a.bien.agence.id = :agenceId)")
    Page<Contrat> findByPersonneIdAndAgence(@Param("personneId") Long personneId,
                                             @Param("agenceId") Long agenceId,
                                             Pageable pageable);
}