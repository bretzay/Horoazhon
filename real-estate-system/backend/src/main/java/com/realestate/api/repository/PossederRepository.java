package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PossederRepository extends JpaRepository<Posseder, Posseder.PossederId> {
    
    // Find by bien
    List<Posseder> findByBienId(Long bienId);
    
    // Find by personne
    List<Posseder> findByPersonneId(Long personneId);
    
    // Check if person owns bien
    boolean existsByBienIdAndPersonneId(Long bienId, Long personneId);
    
    // Delete by bien
    void deleteByBienId(Long bienId);
}
