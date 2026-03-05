# be-agence — Agency operations

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/AgenceController.java`
- **Service**: `backend/src/main/java/com/realestate/api/service/AgenceService.java`
- **DTO**: `backend/src/main/java/com/realestate/api/dto/AgenceDTO.java`
- **Entity**: `backend/src/main/java/com/realestate/api/entity/Agence.java`
- **Security**: @PreAuthorize on POST (SUPER_ADMIN), PUT (SUPER_ADMIN or ADMIN_AGENCY), DELETE (SUPER_ADMIN)

## Developer Notes
- **Status**: Mostly implemented
- @PreAuthorize correctly applied on POST/PUT/DELETE
- ADMIN_AGENCY PUT restricted to own agency via service-layer check
- GET list and GET detail are public (no auth needed) — but SecurityConfig blocks them since they're not under /api/auth/**. Fix needed in SecurityConfig to add permitAll for GET /api/agences and GET /api/agences/*
- GET biens endpoint requires authentication (correct behavior)
- SIRET uniqueness enforced at database level; duplicate → error (handled by exception handler)

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
