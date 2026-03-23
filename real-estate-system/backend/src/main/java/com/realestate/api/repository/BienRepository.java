package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface BienRepository extends JpaRepository<Bien, Long> {

    @Query("SELECT b FROM Bien b " +
           "LEFT JOIN FETCH b.agence " +
           "LEFT JOIN FETCH b.achat " +
           "LEFT JOIN FETCH b.location " +
           "WHERE b.id = :id")
    Optional<Bien> findByIdWithDetails(@Param("id") Long id);
    
    // Find by city
    Page<Bien> findByVille(String ville, Pageable pageable);
    
    // Find by type
    Page<Bien> findByType(String type, Pageable pageable);
    
    // Find by city and type
    Page<Bien> findByVilleAndType(String ville, String type, Pageable pageable);
    
    // Find properties available for sale
    @Query("SELECT b FROM Bien b WHERE b.achat IS NOT NULL")
    Page<Bien> findAvailableForSale(Pageable pageable);
    
    // Find properties available for rent
    @Query("SELECT b FROM Bien b WHERE b.location IS NOT NULL")
    Page<Bien> findAvailableForRent(Pageable pageable);
    
    // Complex filter query with caracteristique and proximity support
    // Public version (no agency filter) - for public property listing
    // Search terms are matched individually against a concatenated text of ville+rue+codePostal+description
    @Query("SELECT DISTINCT b FROM Bien b " +
           "LEFT JOIN b.achat a " +
           "LEFT JOIN b.location l " +
           "WHERE (:s1 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s1) " +
           "AND (:s2 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s2) " +
           "AND (:s3 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s3) " +
           "AND (:s4 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s4) " +
           "AND (:s5 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s5) " +
           "AND (:type IS NULL OR b.type = :type) " +
           "AND (:forSale IS NULL OR (a IS NOT NULL)) " +
           "AND (:forRent IS NULL OR (l IS NOT NULL)) " +
           "AND (:prixMin IS NULL OR a.prix >= :prixMin OR l.mensualite >= :prixMin) " +
           "AND (:prixMax IS NULL OR a.prix <= :prixMax OR l.mensualite <= :prixMax) " +
           "AND (:caracId IS NULL OR EXISTS (SELECT ct FROM Contenir ct WHERE ct.bien = b AND ct.caracteristique.id = :caracId AND (:caracMin IS NULL OR CAST(ct.valeur AS Integer) >= :caracMin))) " +
           "AND (:lieuId IS NULL OR EXISTS (SELECT d FROM Deplacer d WHERE d.bien = b AND d.lieu.id = :lieuId AND (:maxMinutes IS NULL OR d.minutes <= :maxMinutes) AND (:locomotion IS NULL OR d.typeLocomotion = :locomotion)))")
    Page<Bien> findByFilters(
        @Param("s1") String s1,
        @Param("s2") String s2,
        @Param("s3") String s3,
        @Param("s4") String s4,
        @Param("s5") String s5,
        @Param("type") String type,
        @Param("forSale") Boolean forSale,
        @Param("forRent") Boolean forRent,
        @Param("prixMin") BigDecimal prixMin,
        @Param("prixMax") BigDecimal prixMax,
        @Param("caracId") Long caracId,
        @Param("caracMin") Integer caracMin,
        @Param("lieuId") Long lieuId,
        @Param("maxMinutes") Integer maxMinutes,
        @Param("locomotion") String locomotion,
        Pageable pageable
    );

    // Agency-filtered version for authenticated agents
    @Query("SELECT DISTINCT b FROM Bien b " +
           "LEFT JOIN b.achat a " +
           "LEFT JOIN b.location l " +
           "WHERE b.agence.id = :agenceId " +
           "AND (:s1 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s1) " +
           "AND (:s2 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s2) " +
           "AND (:s3 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s3) " +
           "AND (:s4 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s4) " +
           "AND (:s5 IS NULL OR LOWER(CONCAT(COALESCE(b.ville,''),' ',COALESCE(b.rue,''),' ',COALESCE(b.codePostal,''),' ',COALESCE(b.description,''))) LIKE :s5) " +
           "AND (:type IS NULL OR b.type = :type) " +
           "AND (:forSale IS NULL OR (a IS NOT NULL)) " +
           "AND (:forRent IS NULL OR (l IS NOT NULL)) " +
           "AND (:prixMin IS NULL OR a.prix >= :prixMin OR l.mensualite >= :prixMin) " +
           "AND (:prixMax IS NULL OR a.prix <= :prixMax OR l.mensualite <= :prixMax) " +
           "AND (:caracId IS NULL OR EXISTS (SELECT ct FROM Contenir ct WHERE ct.bien = b AND ct.caracteristique.id = :caracId AND (:caracMin IS NULL OR CAST(ct.valeur AS Integer) >= :caracMin))) " +
           "AND (:lieuId IS NULL OR EXISTS (SELECT d FROM Deplacer d WHERE d.bien = b AND d.lieu.id = :lieuId AND (:maxMinutes IS NULL OR d.minutes <= :maxMinutes) AND (:locomotion IS NULL OR d.typeLocomotion = :locomotion)))")
    Page<Bien> findByFiltersAndAgence(
        @Param("agenceId") Long agenceId,
        @Param("s1") String s1,
        @Param("s2") String s2,
        @Param("s3") String s3,
        @Param("s4") String s4,
        @Param("s5") String s5,
        @Param("type") String type,
        @Param("forSale") Boolean forSale,
        @Param("forRent") Boolean forRent,
        @Param("prixMin") BigDecimal prixMin,
        @Param("prixMax") BigDecimal prixMax,
        @Param("caracId") Long caracId,
        @Param("caracMin") Integer caracMin,
        @Param("lieuId") Long lieuId,
        @Param("maxMinutes") Integer maxMinutes,
        @Param("locomotion") String locomotion,
        Pageable pageable
    );
    
    // Find by agency
    Page<Bien> findByAgenceId(Long agenceId, Pageable pageable);

    // Find by agency with actif filter
    Page<Bien> findByAgenceIdAndActif(Long agenceId, Boolean actif, Pageable pageable);
    
    // Find properties owned by a person
    @Query("SELECT b FROM Bien b JOIN b.proprietaires p WHERE p.personne.id = :personneId")
    Page<Bien> findByProprietaireId(@Param("personneId") Long personneId, Pageable pageable);

    // Find active properties owned by a person (for client dashboard)
    @Query("SELECT b FROM Bien b JOIN b.proprietaires p WHERE p.personne.id = :personneId AND b.actif = true")
    Page<Bien> findActiveByProprietaireId(@Param("personneId") Long personneId, Pageable pageable);
}
