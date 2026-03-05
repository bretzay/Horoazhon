# Contract creation
> Spec ID: be-contrat-create | Category: contrat | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/ContratController.java` → POST /api/contrats
- Service: `backend/src/main/java/com/realestate/api/service/ContratService.java`
- DTOs: `CreateContratRequest.java`, `CosignerRequest.java`

### What Exists
- POST /api/contrats — authenticated
- Request: { locationId (optional), achatId (optional), cosigners: [{personneId, typeSignataire}] }
- Exactly one of locationId/achatId required (XOR)
- Minimum 2 cosigners required
- Default statut: EN_COURS

### What's Missing
Nothing — endpoint is complete.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize` on ContratController (SA, AA, AGENT). CLIENT/unauthenticated → 403.
- **XOR validation**: `(locationId == null && achatId == null) || (locationId != null && achatId != null)` → `IllegalArgumentException` → 400. Exactly one must be provided.
- **Minimum cosigners**: `cosigners.size() < 2` → `IllegalArgumentException` → 400. Each cosigner requires `personneId` and `typeSignataire` (enum: OWNER, RENTER, BUYER, SELLER).
- **Cascade persist**: Cosigners are added to the contrat's list before `saveAndFlush()` — JPA cascade persists them in one transaction. `Cosigner.CosignerId` is a composite key (contratId + personneId), auto-set after flush.
- **Default status**: Always `EN_COURS`. No way to create a contract in another status.
- **createdBy**: Sets `contrat.setCreatedBy(securityUtils.getCurrentCompteOrThrow())` — tracks who created the contract.
- **BUG — No agency access check on create**: Any authenticated SA/AA/AGENT can create a contract referencing any listing from any agency. There is no `verifyBienAgencyAccess()` call during creation. A non-SA agent could create a contract on another agency's listing.
- **Invalid IDs**: Invalid `locationId`/`achatId` → `EntityNotFoundException` → 404. Invalid `personneId` in cosigners → `EntityNotFoundException` → 404.
- **Error handling**: `IllegalArgumentException` → 400, `EntityNotFoundException` → 404.

### QA Remarks
- **Test coverage**: 6 suites — valid achat, valid location, both IDs (400), neither ID (400), too few cosigners (400), unauthenticated
- **Edge case**: Invalid personneId in cosigners — should return 400 or 404
- **Edge case**: Invalid locationId or achatId — should return 404
- **Edge case**: Creating contract for a listing in another agency (non-SUPER_ADMIN) — should be blocked

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
