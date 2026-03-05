# Account activation and client invitation
> Spec ID: be-auth-activation | Category: auth | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/AuthController.java` → GET /api/auth/activation-status, POST /api/auth/activate, POST /api/auth/invite-client
- Service: `backend/src/main/java/com/realestate/api/service/AuthService.java`
- DTOs: `ActivateAccountRequest.java`, `InviteClientRequest.java`

### What Exists
- Activation token check: GET /api/auth/activation-status?token=xxx → {valid: true/false}
- Account activation: POST /api/auth/activate with {token, password}
- Client invitation: POST /api/auth/invite-client with {personneId, email, agenceId}
- Tokens: UUID, single-use, 7-day expiry
- BCrypt password hashing on activation

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: All three endpoints are under `/api/auth/**` (`permitAll` in SecurityConfig), so Spring Security annotations won't enforce roles. `invite-client` uses **manual role check** in the controller: verifies `securityUtils.isAuthenticated()`, then checks `isSuperAdmin() || role == ADMIN_AGENCY`. Returns 401/403 manually via `ResponseEntity`.
- **Activation token check** (`GET /api/auth/activation-status`): Calls `compteRepository.findByTokenActivation(token)` then `Compte.isTokenValid()` (checks expiry). Returns `{valid: true/false}`. No error on invalid token — just `false`.
- **Account activation** (`POST /api/auth/activate`): Finds Compte by token, verifies not expired, BCrypt-encodes the password, then **clears token fields** (tokenActivation=null, tokenExpiration=null) → single-use. Throws `IllegalArgumentException` → 400 for invalid/expired tokens.
- **Client invitation** (`POST /api/auth/invite-client`): Creates a new `Compte` with role=CLIENT, UUID activation token, 7-day expiry. Validates: duplicate email check (`existsByEmail`), duplicate person check (`existsByPersonneId`), personne/agence existence. SUPER_ADMIN must provide `agenceId`; ADMIN_AGENCY auto-uses their own. Returns the activation URL.
- **Error handling**: `IllegalArgumentException` → 400 via GlobalExceptionHandler. Email sending is not implemented (token is returned in response for manual use).
- **QA concern confirmed**: AGENT and CLIENT roles are correctly blocked by the manual check in controller code, but this is not enforced by Spring Security — it's a code-level guard, not a framework-level one.

### QA Remarks
- **Test coverage**: 7 suites — invalid token status, activate with bad token, SUPER_ADMIN invite, SA invite without agenceId, AGENT forbidden, unauthenticated invite, ADMIN_AGENCY invite
- **Security concern**: invite-client is under /api/auth/** (permitAll in SecurityConfig) — role check must happen in service layer, not via Spring Security. Verify AGENT and CLIENT cannot call it.
- **Edge case**: invite-client with duplicate email — should return 400
- **Edge case**: Activating with already-used token — should return error
- **Edge case**: SUPER_ADMIN calling invite without agenceId — should return 400

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
