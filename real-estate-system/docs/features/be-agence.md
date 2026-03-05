# Agency operations
> Spec ID: be-agence | Category: agence | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/AgenceController.java`
- Service: `backend/src/main/java/com/realestate/api/service/AgenceService.java`
- DTO: `AgenceDTO.java`

### What Exists
- GET /api/agences — public, returns array
- GET /api/agences/{id} — public detail
- GET /api/agences/{id}/biens — authenticated, paginated
- POST /api/agences — SUPER_ADMIN only (@PreAuthorize)
- PUT /api/agences/{id} — SUPER_ADMIN or own ADMIN_AGENCY
- DELETE /api/agences/{id} — SUPER_ADMIN only (@PreAuthorize)

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization — mixed model**: `GET /api/agences` and `GET /api/agences/{id}` are **public** (no annotations). `POST` and `DELETE` use `@PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")`. `PUT` uses `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY')")` with an additional controller-level check: if the caller is ADMIN_AGENCY, verifies `id.equals(userAgenceId)` — can only update own agency. Other agency → 403.
- **GET /{id}/biens**: Returns paginated properties for a specific agency via `BienService.findByAgenceId()`. No auth required in current code (no annotation on this method, and the controller class has no class-level PreAuthorize).
- **SIRET uniqueness**: Enforced in `AgenceService.create()` — checks for existing SIRET before saving. Throws `IllegalArgumentException` → 400 on duplicate. Also enforced by DB unique constraint → `DataIntegrityViolationException` → 409 as fallback.
- **Delete**: `agenceService.delete()` calls `agenceRepository.deleteById(id)`. **No cascade check** — if the agency has biens, comptes, or other linked entities, the delete will fail with `DataIntegrityViolationException` → 409 (generic constraint violation message, not a descriptive error).
- **Error handling**: `EntityNotFoundException` → 404, `IllegalArgumentException` → 400, `AccessDeniedException` → 403 (from Spring Security annotations), `DataIntegrityViolationException` → 409.

### QA Remarks
- **Test coverage**: 10 suites — public list/detail, 404, SUPER_ADMIN create, ADMIN_AGENCY forbidden create, AGENT forbidden, unauthenticated, own agency update, other agency forbidden update, biens paginated
- **Good**: @PreAuthorize confirmed in code — proper Spring Security enforcement
- **Edge case**: ADMIN_AGENCY updating another agency — must return 403
- **Edge case**: Deleting agency with active contracts — should fail
- **Edge case**: Duplicate SIRET on create — should return 409 or 400

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
