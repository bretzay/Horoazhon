package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.*;
import com.realestate.api.repository.CosignerRepository;
import com.realestate.api.repository.PersonneRepository;
import com.realestate.api.repository.PossederRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class PersonneService {

    private final PersonneRepository personneRepository;
    private final PossederRepository possederRepository;
    private final CosignerRepository cosignerRepository;

    @Transactional(readOnly = true)
    public List<PersonneDTO> findAll() {
        return personneRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public PersonneDTO findById(Long id) {
        Personne personne = personneRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Personne not found with id: " + id));
        return convertToDTO(personne);
    }

    @Transactional(readOnly = true)
    public List<PersonneDTO> search(String query) {
        return personneRepository.findByNomContainingIgnoreCaseOrPrenomContainingIgnoreCase(query, query)
                .stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public PersonneDTO create(CreatePersonneRequest request) {
        Personne personne = new Personne();
        personne.setNom(request.getNom());
        personne.setPrenom(request.getPrenom());
        personne.setDateNais(request.getDateNais());
        personne.setRue(request.getRue());
        personne.setVille(request.getVille());
        personne.setCodePostal(request.getCodePostal());
        personne.setRib(request.getRib());

        Personne saved = personneRepository.save(personne);
        return convertToDTO(saved);
    }

    public PersonneDTO update(Long id, CreatePersonneRequest request) {
        Personne personne = personneRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Personne not found with id: " + id));

        if (request.getNom() != null) personne.setNom(request.getNom());
        if (request.getPrenom() != null) personne.setPrenom(request.getPrenom());
        if (request.getDateNais() != null) personne.setDateNais(request.getDateNais());
        if (request.getRue() != null) personne.setRue(request.getRue());
        if (request.getVille() != null) personne.setVille(request.getVille());
        if (request.getCodePostal() != null) personne.setCodePostal(request.getCodePostal());
        if (request.getRib() != null) personne.setRib(request.getRib());

        Personne saved = personneRepository.save(personne);
        return convertToDTO(saved);
    }

    public void delete(Long id) {
        if (!personneRepository.existsById(id)) {
            throw new EntityNotFoundException("Personne not found with id: " + id);
        }
        personneRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<BienDTO> findBiensByPersonne(Long personneId) {
        if (!personneRepository.existsById(personneId)) {
            throw new EntityNotFoundException("Personne not found with id: " + personneId);
        }
        return possederRepository.findByPersonneId(personneId).stream()
                .map(posseder -> {
                    Bien bien = posseder.getBien();
                    BienDTO dto = new BienDTO();
                    dto.setId(bien.getId());
                    dto.setRue(bien.getRue());
                    dto.setVille(bien.getVille());
                    dto.setCodePostal(bien.getCodePostal());
                    dto.setType(bien.getType());
                    dto.setSuperficie(bien.getSuperficie());
                    dto.setAvailableForSale(bien.isAvailableForSale());
                    dto.setAvailableForRent(bien.isAvailableForRent());
                    if (bien.getAchat() != null) dto.setSalePrice(bien.getAchat().getPrix());
                    if (bien.getLocation() != null) dto.setMonthlyRent(bien.getLocation().getMensualite());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ContratDTO> findContratsByPersonne(Long personneId) {
        if (!personneRepository.existsById(personneId)) {
            throw new EntityNotFoundException("Personne not found with id: " + personneId);
        }
        return cosignerRepository.findByPersonneId(personneId).stream()
                .map(cosigner -> {
                    Contrat c = cosigner.getContrat();
                    ContratDTO dto = new ContratDTO();
                    dto.setId(c.getId());
                    dto.setDateCreation(c.getDateCreation());
                    dto.setStatut(c.getStatut().name());
                    dto.setType(c.getType() != null ? c.getType().name() : null);
                    Bien bien = null;
                    if (c.getLocation() != null) bien = c.getLocation().getBien();
                    else if (c.getAchat() != null) bien = c.getAchat().getBien();
                    if (bien != null) {
                        BienDTO bienDTO = new BienDTO();
                        bienDTO.setId(bien.getId());
                        bienDTO.setRue(bien.getRue());
                        bienDTO.setVille(bien.getVille());
                        bienDTO.setType(bien.getType());
                        dto.setBien(bienDTO);
                    }
                    return dto;
                })
                .collect(Collectors.toList());
    }

    private PersonneDTO convertToDTO(Personne p) {
        PersonneDTO dto = new PersonneDTO();
        dto.setId(p.getId());
        dto.setNom(p.getNom());
        dto.setPrenom(p.getPrenom());
        dto.setDateNais(p.getDateNais());
        dto.setRue(p.getRue());
        dto.setVille(p.getVille());
        dto.setCodePostal(p.getCodePostal());
        dto.setAvoirs(p.getAvoirs());
        dto.setRib(p.getRib());
        return dto;
    }
}