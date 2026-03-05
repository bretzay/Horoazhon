# Person operations
> Spec ID: be-personne | Category: personne | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/PersonneController.java`
- Service: `backend/src/main/java/com/realestate/api/service/PersonneService.java`
- DTOs: `PersonneDTO.java`, `CreatePersonneRequest.java`

### What Exists
- Full CRUD: GET list, GET search, GET detail, POST create, PUT update, DELETE
- Sub-resources: account-status, biens, contrats
- Agency scoping: SUPER_ADMIN sees all, others scoped to own agency
- Search: case-insensitive, accent-insensitive (native SQL)
- No @PreAuthorize — relies on general authentication

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")` on `PersonneController`. CLIENT/unauthenticated → 403.
- **Agency isolation** (list and search): `PersonneService` checks `securityUtils.getCurrentAgenceId()`. If non-null (AA/AGENT), calls `personneRepository.findByAgence(agenceId)` which joins through `Compte.agence_id`. SUPER_ADMIN (agenceId=null) gets all persons. **Note**: Persons without a Compte are invisible to non-SA users (no Compte → no agency link → excluded from agency-scoped queries).
- **Search**: `PersonneService.search()` uses two repository methods depending on agency scope: `searchByAgence(agenceId, query)` or `searchByNameIgnoreAccents(query)`. Both use **native SQL** with `COLLATE Latin1_General_CI_AI` (SQL Server-specific) for case-insensitive, accent-insensitive matching. Searches nom and prenom fields.
- **Account-status** (`GET /{id}/account-status`): Implemented in the controller directly (not in service). Calls `compteRepository.findByPersonneId(id)`. Maps to ACTIVE (password set), PENDING (token valid), or EXPIRED (token expired). If no Compte found, returns `{hasAccount: false}`.
- **Sub-resources**: `/{id}/biens` via `PossederRepository.findByPersonneId()` (ownership), `/{id}/contrats` via `CosignerRepository.findByPersonneId()` (cosigner relation).
- **Delete**: `personneRepository.deleteById(id)` — no cascade check. If the person is linked to contracts (via Cosigner), biens (via Posseder), or an account (Compte), the delete will fail with `DataIntegrityViolationException` → 409.
- **No cross-agency check on detail/update/delete**: `findById`, `update`, and `delete` don't verify the person belongs to the caller's agency. A non-SA user could access/modify any person by ID.
- **Error handling**: `EntityNotFoundException` → 404, `DataIntegrityViolationException` → 409.

### QA Remarks
- **Test coverage**: 9 suites — SUPER_ADMIN list, detail, 404, search, search no results, unauthenticated, account-status with/without account, biens sub-resource
- **Agency isolation**: Verify non-SUPER_ADMIN cannot access personnes from other agencies
- **Edge case**: Search with accented characters (Eric, Francois) — verify accent-insensitive search works
- **Edge case**: Delete personne linked to contracts — should fail or cascade appropriately
- **Edge case**: account-status for person without Compte — should return { hasAccount: false }

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
