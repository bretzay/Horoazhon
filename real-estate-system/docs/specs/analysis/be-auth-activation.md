# be-auth-activation — Account activation and client invitation

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/AuthController.java`
  - `checkActivationToken` (line 38-42)
  - `activateAccount` (line 32-36)
  - `inviteClient` (line 44-70)
- **Service**: `backend/src/main/java/com/realestate/api/service/AuthService.java`
  - `isTokenValid` (line 106-110)
  - `activateAccount` (line 92-104)
  - `createClientAccount` (line 63-90)
- **Entity**: `backend/src/main/java/com/realestate/api/entity/Compte.java` — `isTokenValid()` (line 70-74)

## Developer Notes
- **Status**: Partial implementation
- **CRITICAL GAP**: `inviteClient` endpoint has NO role enforcement — any authenticated user (including CLIENT) can invoke it. The endpoint is under `/api/auth/**` which is permitAll in SecurityConfig, so `@PreAuthorize` won't work. Role check must be manual in controller.
- Activation flow works: token validation, BCrypt password hashing, token invalidation (single-use)
- Token expiry: 7 days (set in `createClientAccount` line 86)
- Duplicate email check exists (line 64)
- SUPER_ADMIN must provide agenceId (handled line 51-57)

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
