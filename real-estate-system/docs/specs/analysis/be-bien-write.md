# be-bien-write — Property create, update, delete and sub-resources

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/BienController.java` (line 65-157)
- **Service**: `backend/src/main/java/com/realestate/api/service/BienService.java`
  - `create` (line 225-249)
  - `update` (line 251-265)
  - `delete` (line 272-277)
  - Sub-resources: `addCaracteristique`, `removeCaracteristique`, `addLieu`, `removeLieu`, `setProprietaire`, `removeProprietaire`, `addPhoto`, `removePhoto`

## Developer Notes
- **Status**: Partial implementation
- **CRITICAL GAP**: No role enforcement — any authenticated user (including CLIENT) can create/update/delete properties. No `@PreAuthorize` annotations on BienController.
- **CRITICAL GAP**: No agency scoping on update/delete — a user from Agency A can modify properties from Agency B. Must verify `bien.getAgence().getId().equals(currentAgenceId)` for non-SUPER_ADMIN users.
- Create auto-links to current user's agency (line 236-245) — works correctly
- Sub-resource operations also lack role/agency checks
- Fix needed: add @PreAuthorize on all write methods, add agency ownership checks in service layer

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
