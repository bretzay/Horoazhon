# Rental and sale listing operations
> Spec ID: be-listing | Category: bien | Status: not_tested

## Implementation

### Files
- Controllers: `backend/src/main/java/com/realestate/api/controller/LocationController.java`, `AchatController.java`
- Services: `LocationService.java`, `AchatService.java`
- DTOs: `LocationDTO.java`, `AchatDTO.java`, `CreateLocationRequest.java`, `CreateAchatRequest.java`

### What Exists
- Full CRUD for Location (rental): GET/POST/PUT/DELETE /api/locations
- Full CRUD for Achat (sale): GET/POST/PUT/DELETE /api/achats
- UNIQUE constraint on bien_id — one listing per type per property
- Dual listing: a property can have both Location and Achat

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")` on both `LocationController` and `AchatController`. All endpoints require SA/AA/AGENT. CLIENT/unauthenticated → 403.
- **Agency access enforcement**: `LocationService` and `AchatService` both use `verifyBienAgencyAccess(bien)` which compares `securityUtils.getCurrentAgenceId()` with `bien.getAgence().getId()`. SUPER_ADMIN bypasses. Non-SA accessing another agency's listing → `SecurityException` → 403.
- **Conflict check on create**: `LocationService.create()` checks `bien.getLocation() != null` → `IllegalStateException("Bien already has a rental listing")` → 409. Same for `AchatService.create()` with `bien.getAchat()`. A property CAN have both a Location AND an Achat (dual listing), but not two of the same type.
- **LocationDTO enrichment**: Response includes bien metadata: `bienId`, `bienType`, `bienRue`, `bienVille` — useful for list views without needing a separate bien fetch.
- **Update**: Partial update pattern — only non-null fields in the request are applied.
- **Delete**: Deletes the listing record. No cascade check for active contracts on that listing — will fail with `DataIntegrityViolationException` → 409 if contracts exist.
- **Error handling**: `EntityNotFoundException` → 404 (bien or listing not found), `IllegalStateException` → 409 (duplicate listing), `SecurityException` → 403 (agency mismatch).

### QA Remarks
- **Test coverage**: 6 suites — location list, achat list, unauthenticated 403 (both), location detail, achat detail
- **Missing test**: Create/update/delete operations — need to test with owned vs non-owned property
- **Edge case**: Duplicate listing on same property — should return 409
- **Edge case**: Creating listing for nonexistent bien — should return 404
- **Edge case**: No @PreAuthorize — verify permission enforcement in service layer

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
