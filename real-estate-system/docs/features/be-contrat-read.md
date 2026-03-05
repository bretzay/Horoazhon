# Contract listing and detail
> Spec ID: be-contrat-read | Category: contrat | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/ContratController.java` → GET /api/contrats, GET /api/contrats/{id}
- Service: `backend/src/main/java/com/realestate/api/service/ContratService.java`
- DTOs: `ContratDTO.java`, `ContratDetailDTO.java`

### What Exists
- GET /api/contrats — authenticated, paginated, sorted by dateCreation DESC
- GET /api/contrats/{id} — authenticated, returns ContratDetailDTO with cosigners, location/achat, siblingContratCount
- Agency isolation: ADMIN_AGENCY/AGENT see only their agency's contracts, SUPER_ADMIN sees all
- Statut values: EN_COURS, SIGNE, ANNULE, TERMINE

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")` on `ContratController`. CLIENT/unauthenticated → 403.
- **Agency isolation** (list): `ContratService.findAll()` checks `securityUtils.getCurrentAgenceId()`. If non-null (AA/AGENT), calls `contratRepository.findByAgence(agenceId, pageable)` which uses a JPQL query joining through `location.bien.agence` and `achat.bien.agence`. SUPER_ADMIN (agenceId=null) gets `findAll()`.
- **Detail**: `contratRepository.findByIdWithDetails(id)` uses `LEFT JOIN FETCH` for eager loading of cosigners, location, achat, and their linked entities. No agency check on detail — any SA/AA/AGENT can view any contract by ID (potential security gap for cross-agency access).
- **siblingContratCount**: Counts other `EN_COURS` contracts on the same offer (location or achat). Queries `findByLocationId` or `findByAchatId`, filters to EN_COURS, excludes current contract. This is calculated on-the-fly, not stored.
- **Contract with no cosigners**: The `cosigners` list would be empty in the response, not null. No validation prevents this state (though creation requires >= 2 cosigners).
- **Error handling**: `EntityNotFoundException` → 404 via GlobalExceptionHandler.

### QA Remarks
- **Test coverage**: 6 suites — SUPER_ADMIN list, detail with cosigners, 404, unauthenticated, ADMIN_AGENCY list, AGENT list
- **Agency isolation**: Critical — must verify ADMIN_AGENCY cannot see contracts from other agencies
- **Edge case**: siblingContratCount accuracy — verify it correctly counts other EN_COURS contracts on same offer
- **Edge case**: Contract with no cosigners — should this be possible?

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
