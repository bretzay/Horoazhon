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
public interface ContratRepository extends JpaRepository<Contrat, Long> {
    
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
}