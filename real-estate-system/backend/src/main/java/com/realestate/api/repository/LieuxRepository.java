package com.realestate.api.repository;

import com.realestate.api.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LieuxRepository extends JpaRepository<Lieux, Long> {
    
    // Find by label
    Optional<Lieux> findByLib(String lib);
    
    // Find all ordered by label
    List<Lieux> findAllByOrderByLibAsc();
}
