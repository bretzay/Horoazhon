package com.realestate.api.repository;

import com.realestate.api.entity.AgencePersonne;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AgencePersonneRepository extends JpaRepository<AgencePersonne, AgencePersonne.AgencePersonneId> {

    List<AgencePersonne> findByAgenceId(Long agenceId);

    List<AgencePersonne> findByPersonneId(Long personneId);

    @Query("SELECT ap.personne.id FROM AgencePersonne ap WHERE ap.agence.id = :agenceId")
    List<Long> findPersonneIdsByAgenceId(@Param("agenceId") Long agenceId);

    @Query("SELECT ap.agence.id FROM AgencePersonne ap WHERE ap.personne.id = :personneId")
    List<Long> findAgenceIdsByPersonneId(@Param("personneId") Long personneId);

    boolean existsByAgenceIdAndPersonneId(Long agenceId, Long personneId);
}
