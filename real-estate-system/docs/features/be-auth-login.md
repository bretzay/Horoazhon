# Authentication (login)
> Spec ID: be-auth-login | Category: auth | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/AuthController.java` → POST /api/auth/login
- Service: `backend/src/main/java/com/realestate/api/service/AuthService.java`
- DTOs: `LoginRequest.java`, `AuthenticationResponse.java`

### What Exists
- POST /api/auth/login — public endpoint
- JWT token generation on successful login
- Role-specific metadata in response (token, role, nom, prenom, agenceId, agenceNom, agenceLogo, personneId)
- Multi-agency flow (token=null, agencies array) when user belongs to multiple agencies
- Anti-enumeration: generic 401 message for both wrong email and wrong password
- BCrypt password verification

### What's Missing
- Multi-agency login not yet implemented (future feature)

## Remarks

### Developer Notes
- **Authorization**: Public endpoint (`/api/auth/**` is `permitAll` in SecurityConfig). No `@PreAuthorize`.
- **Authentication flow**: Spring `AuthenticationManager.authenticate()` delegates to `CompteUserDetailsService.loadUserByUsername()`. BCrypt verification is handled by Spring Security's `DaoAuthenticationProvider`. Failed auth throws `BadCredentialsException` → caught by Spring Security → 401.
- **Inactive/unactivated accounts**: `CompteUserDetailsService` checks `compte.getActif()` and `compte.isActivated()`. If either is false, throws `UsernameNotFoundException` → Spring treats as bad credentials → same 401 message (anti-enumeration preserved).
- **JWT claims**: Token includes `role`, `agenceId`, `personneId` as custom claims. Expiry is configured via `app.jwt.expiration` (default 24h). Token is signed with HMAC-SHA256 (`app.jwt.secret`).
- **Response shape**: `AuthenticationResponse` DTO with fields: token, role, nom, prenom, agenceId, agenceNom, agenceLogo, personneId.
- **Error handling**: `BadCredentialsException` / `UsernameNotFoundException` → 401 (handled by Spring Security filter chain, not GlobalExceptionHandler). Generic message: authentication fails before reaching the controller.
- **Edge cases**: SUPER_ADMIN has `agenceId=null` in both JWT claims and response. Multi-agency login (token=null, agencies array) is designed in DTO but not yet implemented in service.

### QA Remarks
- **Test coverage**: 7 suites — valid login for SUPER_ADMIN/ADMIN_AGENCY/AGENT, wrong password, nonexistent email, empty body, missing field
- **Anti-enumeration verification**: Same 401 message for wrong email vs wrong password — critical security requirement
- **Edge case**: Login with deactivated account (actif=false) — should return 401
- **Edge case**: Login with unactivated account (pending activation) — behavior needs verification
- **Missing**: No CLIENT test account in seed data — cannot test CLIENT login flow

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
