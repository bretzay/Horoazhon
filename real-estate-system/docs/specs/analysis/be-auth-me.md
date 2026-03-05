# be-auth-me — Current user profile

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/AuthController.java` (line 93-113)
- **Service**: Uses `CompteUserDetailsService.loadCompteByEmail()` directly in controller
- **Security**: Under `/api/auth/**` permitAll, but controller manually checks `authentication == null`

## Developer Notes
- **Status**: Fully implemented
- Returns HashMap (not typed DTO): id, email, nom, prenom, role, agenceId, agenceNom, agenceLogo, personneId
- Manual null check for authentication at controller level (line 95-97)
- No gaps found

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
