package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CosignerRepository extends JpaRepository<Cosigner, Cosigner.CosignerId> {
    
    // Find by contract
    List<Cosigner> findByContratId(Long contratId);
    
    // Find by person
    List<Cosigner> findByPersonneId(Long personneId);
    
    // Find by type
    List<Cosigner> findByTypeSignataire(Cosigner.TypeSignataire typeSignataire);
    
    // Count signers for a contract
    long countByContratId(Long contratId);
    
    // Check if person already signed contract
    boolean existsByContratIdAndPersonneId(Long contratId, Long personneId);
}
