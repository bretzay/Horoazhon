# be-contrat-read — Contract listing and detail

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/ContratController.java`
- **Service**: `backend/src/main/java/com/realestate/api/service/ContratService.java`
  - `findAll` (line 43-50) — agency isolation via securityUtils
  - `findById` (line 52-57)
- **DTOs**: `ContratDTO.java`, `ContratDetailDTO.java`, `CosignerDTO.java`
- **Repository**: `ContratRepository.java` — `findByAgence()`, `findByIdWithDetails()`

## Developer Notes
- **Status**: Fully implemented
- Agency isolation works: non-SUPER_ADMIN users see only contracts linked to biens in their agency
- TypeSignataire uses English values (BUYER, SELLER, RENTER, OWNER) — confirmed OK by user
- Statut values: EN_COURS, SIGNE, ANNULE, TERMINE — no EXPIRE status (confirmed OK by user, removed from spec)
- ContratDetailDTO includes siblingContratCount (other EN_COURS contracts on same offer)
- Type is auto-inferred: LOCATION or ACHAT based on which FK is set

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
