# Current user profile
> Spec ID: be-auth-me | Category: auth | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/AuthController.java` → GET /api/auth/me
- Service: `backend/src/main/java/com/realestate/api/service/AuthService.java`

### What Exists
- GET /api/auth/me — returns authenticated user info
- Response: { id, email, nom, prenom, role, agenceId, agenceNom, agenceLogo, personneId }
- Any authenticated user can call this
- Token validation via JWT filter

### What's Missing
Nothing — endpoint is complete.

## Remarks

### Developer Notes
- **Authorization**: Manual check — no `@PreAuthorize`. Controller checks `authentication == null || !authentication.isAuthenticated()` and returns 401 manually. This is inconsistent with other secured endpoints that use annotations.
- **Data source**: Calls `userDetailsService.loadCompteByEmail(authentication.getName())` to reload the full `Compte` entity from DB. This means the response reflects current DB state, not stale JWT claims.
- **Response shape**: Returns a raw `Map<String, Object>` (not a DTO): id, email, nom, prenom, role, agenceId, agenceNom, agenceLogo, personneId. SUPER_ADMIN will have agenceId/agenceNom/agenceLogo as null.
- **Error handling**: If the account is deleted after the JWT was issued, `loadCompteByEmail` throws `UsernameNotFoundException` → no handler for this in the controller → bubbles up to Spring Security → **returns 500** (not 401). This is a known bug.
- **Edge cases**: Expired JWT is handled by the JWT filter before reaching this controller (returns 401/403). Malformed `Authorization` header (non-Bearer) also handled by the filter chain.

### QA Remarks
- **Test coverage**: 4 suites — SUPER_ADMIN profile, ADMIN_AGENCY profile, unauthenticated (401), invalid token
- **Edge case**: Expired JWT — verify returns 401/403 with clear message
- **Edge case**: Malformed Authorization header (e.g., "Bearer invalid", "Basic xxx") — verify proper error
- **Verify**: SUPER_ADMIN response has agenceId=null, agenceNom=null

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
