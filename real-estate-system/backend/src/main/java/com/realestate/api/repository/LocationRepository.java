package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface LocationRepository extends JpaRepository<Location, Long> {
    
    // Find by bien
    Optional<Location> findByBienId(Long bienId);
    
    // Find by price range
    List<Location> findByMensualiteBetween(BigDecimal min, BigDecimal max);
    
    // Find available locations
    @Query("SELECT l FROM Location l WHERE l.dateDispo <= CURRENT_DATE " +
           "AND NOT EXISTS (SELECT 1 FROM Contrat c WHERE c.location = l AND c.statut = 'SIGNE')")
    List<Location> findAvailableLocations();

    // Agency-filtered
    @Query("SELECT l FROM Location l WHERE l.bien.agence.id = :agenceId")
    List<Location> findByBienAgenceId(@Param("agenceId") Long agenceId);
}
