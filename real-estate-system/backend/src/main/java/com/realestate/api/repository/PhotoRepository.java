package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PhotoRepository extends JpaRepository<Photo, Long> {
    
    // Find photos by bien, ordered by ordre
    List<Photo> findByBienIdOrderByOrdreAsc(Long bienId);
    
    // Find principal photo (ordre = 1)
    Optional<Photo> findByBienIdAndOrdre(Long bienId, Integer ordre);
    
    // Delete all photos for a bien
    void deleteByBienId(Long bienId);
}
