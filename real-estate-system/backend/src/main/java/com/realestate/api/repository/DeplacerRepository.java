package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DeplacerRepository extends JpaRepository<Deplacer, Deplacer.DeplacerId> {
    
    // Find by bien
    List<Deplacer> findByBienId(Long bienId);
    
    // Find by lieu
    List<Deplacer> findByLieuId(Long lieuId);
    
    // Find by travel time
    List<Deplacer> findByMinutesLessThanEqual(Integer maxMinutes);
    
    // Delete by bien
    void deleteByBienId(Long bienId);
}
