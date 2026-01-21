package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ContenirRepository extends JpaRepository<Contenir, Contenir.ContenirId> {
    
    // Find by bien
    List<Contenir> findByBienId(Long bienId);
    
    // Find by caracteristique
    List<Contenir> findByCaracteristiqueId(Long caracteristiqueId);
    
    // Delete by bien
    void deleteByBienId(Long bienId);
}
