# be-auth-password-change — Authenticated password change

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/AuthController.java` — endpoint DOES NOT EXIST
- **Service**: `backend/src/main/java/com/realestate/api/service/AuthService.java` — method DOES NOT EXIST

## Developer Notes
- **Status**: NOT IMPLEMENTED
- Endpoint POST /api/auth/change-password must be created
- Requires: ChangePasswordRequest DTO (currentPassword, newPassword)
- Must verify current password with BCrypt before allowing change
- Must validate newPassword length >= 6
- Under /api/auth/** (permitAll), so authentication check must be manual in controller
- Implementation planned in Phase B of current session

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
