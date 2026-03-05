# User account operations
> Spec ID: be-user | Category: utilisateur | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/UserController.java`
- Service: `backend/src/main/java/com/realestate/api/service/AuthService.java` (user creation reuses auth service)

### What Exists
- GET /api/users — paginated (default size 20)
- POST /api/users — creates Personne + Compte with activation token
- DELETE /api/users/{id} — soft-delete (actif=false)
- PUT /api/users/{id}/reactivate — re-enables deactivated account
- No @PreAuthorize — role enforcement in service layer

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY')")`. Spring Security enforces that only SA and AA can access any endpoint. AGENT/CLIENT get 403.
- **Agency scoping**: `GET /api/users` — SUPER_ADMIN sees all users (`findAll`), ADMIN_AGENCY sees only their agency's users (`findByAgenceId`). Detail/deactivate/reactivate also enforce agency checks manually in controller code.
- **Role hierarchy**: `createUser` enforces `newRole.ordinal() >= currentCompte.getRole().ordinal()` → 403. Role enum order: SUPER_ADMIN(0), ADMIN_AGENCY(1), AGENT(2), CLIENT(3). So AA can create AGENT/CLIENT but not AA/SA.
- **User creation flow**: Creates a `Personne` entity first (with default DOB 1990-01-01 if not provided), then creates `Compte` with UUID activation token (7-day expiry), no password. Optionally sends activation email if `activationBaseUrl` is provided in the request body.
- **BUG — RuntimeException → 500**: `getUserById`, `deactivateUser`, `reactivateUser` all use `compteRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"))`. `RuntimeException` is not caught by GlobalExceptionHandler (only `EntityNotFoundException`, `IllegalArgumentException`, etc. are). This causes a **500 Internal Server Error** instead of 404. Same bug in `createUser` when SUPER_ADMIN provides a bad `agenceId` (`new RuntimeException("Agence not found")`).
- **Deactivate**: Soft-delete — sets `actif=false`. Also enforces role hierarchy (can't deactivate equal or higher role). No check for "last SUPER_ADMIN" scenario.
- **Reactivate**: Sets `actif=true`. Same role hierarchy and agency checks. Not idempotent — calling on already-active user just re-saves with actif=true (no error, returns 204).
- **Duplicate email**: `createUser` checks `compteRepository.existsByEmail(email)` → returns 400 with error message.

### QA Remarks
- **Test coverage**: 8 suites — SUPER_ADMIN list, ADMIN_AGENCY list, SUPER_ADMIN create, SA create no agence (400), equal role forbidden (403), duplicate email (400), unauthenticated, AGENT forbidden
- **Role hierarchy enforcement**: ADMIN_AGENCY cannot create ADMIN_AGENCY or SUPER_ADMIN — critical security rule
- **Edge case**: Deactivating the last SUPER_ADMIN — should fail
- **Edge case**: Reactivating already-active user — should be idempotent (204)
- **Edge case**: AGENT attempting any user operation — should return 403

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
