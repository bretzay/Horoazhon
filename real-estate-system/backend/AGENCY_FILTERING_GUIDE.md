# Agency Filtering Implementation Guide

## ✅ Completed:

### 1. Repository Updates (ALL DONE)

**BienRepository:**
- Added `findByFiltersAndAgence()` - agency-filtered version of main query
- Original `findByFilters()` remains for public listing
- Existing `findByAgenceId()` available

**ContratRepository:**
- Added `findByAgence()` - get all contracts for an agency
- Added `findByAgenceAndStatut()` - filter by agency + status
- Added `findByPersonneIdAndAgence()` - contracts for a person within agency

**PersonneRepository:**
- Added `findByAgence()` - get all customers for an agency (via AgencePersonne)
- Added `searchByAgence()` - search customers within agency
- Added `findProprietairesByAgence()` - get all property owners in agency

**SecurityUtils:**
- Utility class to get current agent from security context
- Methods: `getCurrentAgent()`, `getCurrentAgenceId()`, `isAuthenticated()`

---

## 🔧 Service Updates Needed:

### BienService Changes:

```java
// Add SecurityUtils injection
private final SecurityUtils securityUtils;

// Update findAll to use agency filtering
public Page<BienDTO> findAll(...) {
    if (securityUtils.isAuthenticated()) {
        Long agenceId = securityUtils.getCurrentAgenceId();
        return bienRepository.findByFiltersAndAgence(
            agenceId, ville, type, forSale, forRent, prixMin, prixMax,
            caracId, caracMin, lieuId, maxMinutes, locomotion, pageable
        ).map(this::convertToDTO);
    } else {
        // Public access - no agency filter
        return bienRepository.findByFilters(...).map(this::convertToDTO);
    }
}

// Update create to set creator and validate agency
public BienDTO create(CreateBienRequest request) {
    Agent currentAgent = securityUtils.getCurrentAgentOrThrow();
    
    // Validate agenceId matches current agent's agency
    if (request.getAgenceId() != null && 
        !request.getAgenceId().equals(currentAgent.getAgence().getId())) {
        throw new IllegalArgumentException("Cannot create property for another agency");
    }
    
    Bien bien = new Bien();
    // ... set fields ...
    bien.setAgence(currentAgent.getAgence());
    bien.setCreatedBy(currentAgent);  // Track creator
    
    return convertToDTO(bienRepository.save(bien));
}

// Update update/delete to verify ownership
public BienDTO update(Long id, UpdateBienRequest request) {
    Bien bien = bienRepository.findById(id).orElseThrow(...);
    
    // Verify the bien belongs to the current agent's agency
    Long currentAgenceId = securityUtils.getCurrentAgenceId();
    if (!bien.getAgence().getId().equals(currentAgenceId)) {
        throw new SecurityException("Cannot modify property from another agency");
    }
    
    // ... update fields ...
    return convertToDTO(bienRepository.save(bien));
}

// Similar check in delete, addProprietaire, addCaracteristique, etc.
```

### ContratService Changes:

```java
// Add SecurityUtils injection
private final SecurityUtils securityUtils;

// Update findAll to filter by agency
public Page<ContratDTO> findAll(Pageable pageable) {
    if (securityUtils.isAuthenticated()) {
        Long agenceId = securityUtils.getCurrentAgenceId();
        return contratRepository.findByAgence(agenceId, pageable)
                .map(this::convertToDTO);
    } else {
        // No public access to contracts
        throw new SecurityException("Authentication required");
    }
}

// Update create to set creator and validate
public ContratDTO create(CreateContratRequest request) {
    Agent currentAgent = securityUtils.getCurrentAgentOrThrow();
    
    // Verify the property (via achat/location) belongs to current agency
    if (request.getAchatId() != null) {
        Achat achat = achatRepository.findById(request.getAchatId()).orElseThrow(...);
        if (!achat.getBien().getAgence().getId().equals(currentAgent.getAgence().getId())) {
            throw new SecurityException("Cannot create contract for property from another agency");
        }
    } else if (request.getLocationId() != null) {
        Location location = locationRepository.findById(request.getLocationId()).orElseThrow(...);
        if (!location.getBien().getAgence().getId().equals(currentAgent.getAgence().getId())) {
            throw new SecurityException("Cannot create contract for property from another agency");
        }
    }
    
    Contrat contrat = new Contrat();
    // ... set fields ...
    contrat.setCreatedBy(currentAgent);  // Track creator
    
    return convertToDTO(contratRepository.save(contrat));
}

// Update/delete - verify contract belongs to agency
```

### PersonneService Changes:

```java
// Add SecurityUtils injection
private final SecurityUtils securityUtils;

// Update findAll to filter by agency
public Page<PersonneDTO> findAll(Pageable pageable) {
    if (securityUtils.isAuthenticated()) {
        Long agenceId = securityUtils.getCurrentAgenceId();
        return personneRepository.findByAgence(agenceId, pageable)
                .map(this::convertToDTO);
    } else {
        throw new SecurityException("Authentication required");
    }
}

// When creating/linking a person, create AgencePersonne record
public PersonneDTO create(CreatePersonneRequest request) {
    Agent currentAgent = securityUtils.getCurrentAgentOrThrow();
    
    Personne personne = new Personne();
    // ... set fields ...
    Personne saved = personneRepository.save(personne);
    
    // Link to current agency
    AgencePersonne link = new AgencePersonne();
    link.setId(new AgencePersonne.AgencePersonneId(
        currentAgent.getAgence().getId(), saved.getId()
    ));
    link.setAgence(currentAgent.getAgence());
    link.setPersonne(saved);
    agencePersonneRepository.save(link);
    
    return convertToDTO(saved);
}

// search() - use searchByAgence
public List<PersonneDTO> search(String query) {
    Long agenceId = securityUtils.getCurrentAgenceId();
    return personneRepository.searchByAgence(agenceId, query)
            .stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
}
```

---

## 📝 Implementation Steps:

1. **Inject SecurityUtils** in each service constructor
2. **Update all findAll/search methods** to use agency-filtered queries
3. **Add agency validation** in all create/update/delete methods
4. **Set createdBy** field when creating Bien or Contrat
5. **Create AgencePersonne links** when creating/importing customers
6. **Test each endpoint** to ensure agents can't access other agencies' data

---

## ⚠️ Important Notes:

- **Public endpoints** (property listing for website visitors) should NOT use agency filtering
- **Authentication required endpoints** MUST always filter by agency
- **Creator tracking** helps with auditing and dispute resolution
- **AgencePersonne links** allow customers to work with multiple agencies
- Always validate that resources belong to the current agent's agency before modification

---

## 🧪 Testing:

Create agents in different agencies and verify:
1. Agent A cannot see Agent B's properties
2. Agent A cannot modify Agent B's contracts
3. Agent A cannot access Agent B's customers
4. Public property listing still works for all properties
5. Agent creation restricted to same agency
