package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface AchatRepository extends JpaRepository<Achat, Long> {
    
    // Find by bien
    Optional<Achat> findByBienId(Long bienId);
    
    // Find by price range
    List<Achat> findByPrixBetween(BigDecimal min, BigDecimal max);
    
    // Find available purchases
    @Query("SELECT a FROM Achat a WHERE a.dateDispo <= CURRENT_DATE " +
           "AND NOT EXISTS (SELECT 1 FROM Contrat c WHERE c.achat = a AND c.statut = 'SIGNE')")
    List<Achat> findAvailableAchats();
}
