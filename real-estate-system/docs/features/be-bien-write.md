# Property create, update, delete and sub-resources
> Spec ID: be-bien-write | Category: bien | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/BienController.java` → POST/PUT/DELETE /api/biens, sub-resource endpoints
- Service: `backend/src/main/java/com/realestate/api/service/BienService.java`
- DTOs: `CreateBienRequest.java`, `UpdateBienRequest.java`

### What Exists
- Full CRUD: POST (create), PUT (update), DELETE (delete)
- Sub-resources: caracteristiques, lieux, proprietaire, photos
- Agency scoping: non-SUPER_ADMIN restricted to own agency's properties
- No @PreAuthorize — role enforcement in service layer

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: Method-level `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")` on all write endpoints (POST, PUT, DELETE, sub-resources). CLIENT role gets 403 from Spring Security.
- **Agency access enforcement**: `verifyAgencyAccess(bien)` in BienService — compares `securityUtils.getCurrentAgenceId()` with `bien.getAgence().getId()`. SUPER_ADMIN bypasses (agenceId=null). Non-SA editing another agency's property → `AccessDeniedException` → 403.
- **Create**: SUPER_ADMIN must provide `agenceId` in request body (or it's null → no agency link). Non-SA auto-links to their own agency. No agency access check on create — only on update/delete.
- **setProprietaire** (`PUT /{bienId}/proprietaire`): **Deletes ALL existing owners first** via `possederRepository.deleteByBienId(bienId)` + flush, then creates new single owner. This is a replace-all operation, not an add.
- **Photo handling**: `addPhoto` — `ordre` defaults to 1 if not provided. `chemin` is a string URL/path (no actual file upload — just stores the path). `removePhoto` verifies the photo belongs to the specified bien.
- **Caracteristique/Lieu associations**: Duplicate check via `existsById` on composite key → `IllegalStateException` → 409 if already associated.
- **Delete**: `bienRepository.deleteById(id)` — no cascade check for active contracts. If the property has contracts, this will fail with a `DataIntegrityViolationException` → 409 via GlobalExceptionHandler.
- **Error handling**: `EntityNotFoundException` → 404, `AccessDeniedException` → 403, `IllegalStateException` → 409, `IllegalArgumentException` → 400, `DataIntegrityViolationException` → 409.

### QA Remarks
- **Test coverage**: 6 suites — SUPER_ADMIN create, AGENT create, unauthenticated (403), update, delete 404, add caracteristique
- **Permission concern**: No @PreAuthorize annotations — all role enforcement is in service layer. Need to verify CLIENT role cannot create/update/delete properties.
- **Edge case**: AGENT updating a property from another agency — should return 403
- **Edge case**: Deleting a property with active contracts — should fail
- **Edge case**: Photo upload with non-image file or oversized file — verify validation
- **Missing test**: CLIENT role attempting write operations — not currently testable (no CLIENT account in seed data)

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
