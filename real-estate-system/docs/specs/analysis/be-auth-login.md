# be-auth-login — Authentication (login)

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/AuthController.java` (line 26-30)
- **Service**: `backend/src/main/java/com/realestate/api/service/AuthService.java` (line 36-61)
- **DTO Request**: `backend/src/main/java/com/realestate/api/dto/LoginRequest.java`
- **DTO Response**: `backend/src/main/java/com/realestate/api/dto/AuthenticationResponse.java`
- **Security**: `backend/src/main/java/com/realestate/api/security/SecurityConfig.java` — `/api/auth/**` is permitAll
- **JWT**: `backend/src/main/java/com/realestate/api/security/JwtUtil.java`

## Developer Notes
- **Status**: Partial implementation
- Single-agency login works: authenticates via Spring Security AuthenticationManager, generates JWT with role/agenceId/personneId claims
- Multi-agency flow is NOT implemented (future feature per CLAUDE.md Pending API Contracts)
- No rate limiting on login attempts
- Anti-enumeration: Spring Security returns generic 401 on bad credentials (doesn't reveal email existence)
- Response includes: token, role, nom, prenom, agenceId, agenceNom, agenceLogo, personneId

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
