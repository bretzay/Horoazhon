# be-auth-password-reset — Password reset flow

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/AuthController.java`
  - `forgotPassword` (line 74-79)
  - `checkResetToken` (line 81-85)
  - `resetPassword` (line 87-91)
- **Service**: `backend/src/main/java/com/realestate/api/service/AuthService.java`
  - `requestPasswordReset` (line 114-132)
  - `isResetTokenValid` (line 134-138)
  - `resetPassword` (line 140-153)
- **Entity**: `backend/src/main/java/com/realestate/api/entity/Compte.java` — `isResetTokenValid()` (line 76-80)

## Developer Notes
- **Status**: Fully implemented
- Anti-enumeration: `requestPasswordReset` always returns silently even if email doesn't exist (line 118-121)
- Token: UUID, 1-hour expiry (line 125), single-use (nulled after reset, line 150-151)
- Password hashed with BCrypt (line 148)
- Email sending is TODO — currently logs reset URL to console (line 130-131)
- Non-activated accounts are silently skipped (line 119)

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
