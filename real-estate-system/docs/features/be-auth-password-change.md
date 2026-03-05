# Authenticated password change
> Spec ID: be-auth-password-change | Category: auth | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/AuthController.java` → POST /api/auth/change-password
- Service: `backend/src/main/java/com/realestate/api/service/AuthService.java`
- DTO: `ChangePasswordRequest.java`

### What Exists
- POST /api/auth/change-password — authenticated endpoint
- Request: {currentPassword, newPassword}
- BCrypt verification of current password
- BCrypt hashing of new password

### What's Missing
- Spec says "NOT YET IMPLEMENTED" — needs verification. DTO exists but endpoint may not be wired.

## Remarks

### Developer Notes
- **Implementation status**: **Fully implemented.** The endpoint is wired in `AuthController` at `POST /api/auth/change-password`. DTO `ChangePasswordRequest` exists with fields `currentPassword` and `newPassword`. The spec description saying "NOT YET IMPLEMENTED" is outdated.
- **Authorization**: Manual check — no `@PreAuthorize`. Controller checks `securityUtils.isAuthenticated()` and returns 401 manually. Then loads the current `Compte` via `securityUtils.getCurrentCompteOrThrow()`.
- **Business logic**: `AuthService.changePassword()` verifies `currentPassword` matches the stored BCrypt hash via `passwordEncoder.matches()`. If wrong, throws `IllegalArgumentException("Le mot de passe actuel est incorrect")` → 400. Then BCrypt-encodes the new password and saves.
- **No JWT invalidation**: After password change, the existing JWT remains valid until it expires. No token revocation mechanism.
- **Same password allowed**: No check preventing the new password from being identical to the current one.
- **Edge cases**: No minimum password length validation at the service level (depends on DTO `@Size` annotation). Endpoint is under `/api/auth/**` (`permitAll` in SecurityConfig), but the manual auth check in the controller ensures only authenticated users can call it.

### QA Remarks
- **Implementation status unclear**: Spec description says endpoint doesn't exist yet, but DTO file exists. Backend role needs to confirm status.
- **Test coverage**: 3 suites — valid change, wrong current password (400), unauthenticated (401)
- **Edge case**: New password same as current — should this be allowed?
- **Edge case**: Minimum password length (6 chars) — verify validation

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
