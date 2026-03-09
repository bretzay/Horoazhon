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

    @Query("SELECT c FROM Contrat c LEFT JOIN FETCH c.cosigners cs LEFT JOIN FETCH cs.personne LEFT JOIN FETCH c.bien b LEFT JOIN FETCH b.agence WHERE c.id = :id")
    Optional<Contrat> findByIdWithDetails(@Param("id") Long id);

    // Find all contracts linked to a property
    @Query("SELECT DISTINCT c FROM Contrat c " +
           "LEFT JOIN FETCH c.cosigners cs LEFT JOIN FETCH cs.personne " +
           "WHERE c.bien.id = :bienId " +
           "ORDER BY c.dateCreation DESC")
    List<Contrat> findByBienId(@Param("bienId") Long bienId);

    // Find contracts by bien and type
    @Query("SELECT c FROM Contrat c WHERE c.bien.id = :bienId AND c.typeContrat = :typeContrat")
    List<Contrat> findByBienIdAndTypeContrat(@Param("bienId") Long bienId, @Param("typeContrat") Contrat.TypeContrat typeContrat);

    // Find contracts by status
    Page<Contrat> findByStatut(Contrat.StatutContrat statut, Pageable pageable);

    // Find contracts for a specific person (as co-signer)
    @Query("SELECT c FROM Contrat c JOIN c.cosigners cs WHERE cs.personne.id = :personneId")
    Page<Contrat> findByPersonneId(@Param("personneId") Long personneId, Pageable pageable);

    // Find all contracts for a specific person (no pagination, for stats)
    @Query("SELECT c FROM Contrat c JOIN c.cosigners cs WHERE cs.personne.id = :personneId")
    List<Contrat> findAllByPersonneId(@Param("personneId") Long personneId);

    // Find rental contracts
    @Query("SELECT c FROM Contrat c WHERE c.typeContrat = 'LOCATION'")
    Page<Contrat> findRentalContracts(Pageable pageable);

    // Find SIGNE rental contracts with cosigners (for expiration scheduler)
    @Query("SELECT DISTINCT c FROM Contrat c JOIN FETCH c.cosigners " +
           "WHERE c.statut = 'SIGNE' AND c.typeContrat = 'LOCATION'")
    List<Contrat> findSignedRentalContracts();

    // Find purchase contracts
    @Query("SELECT c FROM Contrat c WHERE c.typeContrat = 'ACHAT'")
    Page<Contrat> findPurchaseContracts(Pageable pageable);

    // Check if any contract exists for a bien (any status)
    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Contrat c WHERE c.bien.id = :bienId")
    boolean existsByBienId(@Param("bienId") Long bienId);

    // Check if a SIGNE contract of given type exists for a bien
    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Contrat c WHERE c.bien.id = :bienId AND c.typeContrat = :typeContrat AND c.statut = 'SIGNE'")
    boolean existsSignedByBienIdAndType(@Param("bienId") Long bienId, @Param("typeContrat") Contrat.TypeContrat typeContrat);

    // Check if EN_COURS contracts of given type exist for a bien
    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Contrat c WHERE c.bien.id = :bienId AND c.typeContrat = :typeContrat AND c.statut = 'EN_COURS'")
    boolean existsEnCoursByBienIdAndType(@Param("bienId") Long bienId, @Param("typeContrat") Contrat.TypeContrat typeContrat);

    // Agency-filtered queries
    @Query("SELECT c FROM Contrat c " +
           "JOIN c.bien b " +
           "WHERE b.agence.id = :agenceId")
    Page<Contrat> findByAgence(@Param("agenceId") Long agenceId, Pageable pageable);

    @Query("SELECT c FROM Contrat c " +
           "JOIN c.bien b " +
           "WHERE b.agence.id = :agenceId " +
           "AND c.statut = :statut")
    Page<Contrat> findByAgenceAndStatut(@Param("agenceId") Long agenceId,
                                         @Param("statut") Contrat.StatutContrat statut,
                                         Pageable pageable);

    @Query("SELECT c FROM Contrat c " +
           "JOIN c.cosigners cs " +
           "JOIN c.bien b " +
           "WHERE cs.personne.id = :personneId " +
           "AND b.agence.id = :agenceId")
    Page<Contrat> findByPersonneIdAndAgence(@Param("personneId") Long personneId,
                                             @Param("agenceId") Long agenceId,
                                             Pageable pageable);
}
