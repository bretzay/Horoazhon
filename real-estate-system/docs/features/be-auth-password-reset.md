# Password reset flow
> Spec ID: be-auth-password-reset | Category: auth | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/AuthController.java` → POST /api/auth/forgot-password, GET /api/auth/reset-status, POST /api/auth/reset-password
- Service: `backend/src/main/java/com/realestate/api/service/AuthService.java`
- DTOs: `ForgotPasswordRequest.java`, `ResetPasswordRequest.java`

### What Exists
- Forgot password: POST /api/auth/forgot-password — always returns 200 (anti-enumeration)
- Token check: GET /api/auth/reset-status?token=xxx → {valid: true/false}
- Reset: POST /api/auth/reset-password with {token, password}
- Token: UUID, 1-hour expiry, single-use
- BCrypt password hashing on reset

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: All three endpoints are under `/api/auth/**` (`permitAll`). No authentication required.
- **Forgot password** (`POST /api/auth/forgot-password`): Anti-enumeration — always returns 200 with the same message regardless of whether the email exists. If account exists and is activated, generates UUID token with 1h expiry (`LocalDateTime.now().plusHours(1)`), saves to `token_reset` / `token_reset_expiration` columns. If account doesn't exist or isn't activated, silently returns success.
- **Multiple requests**: Each `forgot-password` call **overwrites** the previous token. Only the latest token is valid. No rate limiting.
- **Token check** (`GET /api/auth/reset-status`): Calls `compteRepository.findByTokenReset(token)` → `Compte.isResetTokenValid()` (checks expiry). Returns `{valid: true/false}`.
- **Reset** (`POST /api/auth/reset-password`): Finds Compte by token, verifies not expired, BCrypt-encodes new password, **clears token fields** (tokenReset=null, tokenResetExpiration=null) → single-use. Throws `IllegalArgumentException` → 400 for invalid/expired tokens.
- **Email sending**: **TODO** — currently only logs the reset URL to console (`log.debug`). Token is not sent via email.
- **Error handling**: `IllegalArgumentException` → 400 via GlobalExceptionHandler.
- **Known edge case**: No minimum password length validation on the DTO (no `@Size` annotation verified — depends on DTO definition).

### QA Remarks
- **Test coverage**: 4 suites — forgot with existing email, forgot with nonexistent (anti-enumeration), invalid reset status, reset with invalid token
- **Anti-enumeration**: forgot-password must return 200 regardless of email existence — critical security requirement
- **Edge case**: Multiple forgot-password requests for same email — does each invalidate the previous token?
- **Edge case**: Reset token used twice — second attempt should return 400
- **Edge case**: Reset token after 1 hour — should return valid=false

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
