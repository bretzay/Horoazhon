# be-user — User account operations

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/UserController.java`
- **Service**: `backend/src/main/java/com/realestate/api/service/UserService.java` (if exists) or logic in controller
- **Entity**: `backend/src/main/java/com/realestate/api/entity/Compte.java`

## Developer Notes
- **Status**: Fully implemented
- Role hierarchy enforcement works via ordinal comparison (CLIENT < AGENT < ADMIN_AGENCY < SUPER_ADMIN)
- Cannot create user with equal or higher role
- SUPER_ADMIN sees all users, ADMIN_AGENCY sees own agency users
- Soft-delete: sets actif=false
- Creates Personne + Compte with activation token
- **Minor gap**: No @PreAuthorize on controller — role enforcement is in service layer. AGENT can technically call the endpoint but service should return 403.
- Agency scoping on user list works

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
