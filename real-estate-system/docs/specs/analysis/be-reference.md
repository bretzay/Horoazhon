# be-reference — Reference data operations

## Codebase Context
- **Controllers**:
  - `backend/src/main/java/com/realestate/api/controller/CaracteristiquesController.java`
  - `backend/src/main/java/com/realestate/api/controller/LieuxController.java`
- **Services**:
  - `backend/src/main/java/com/realestate/api/service/CaracteristiquesService.java`
  - `backend/src/main/java/com/realestate/api/service/LieuxService.java`
- **Repositories**: `CaracteristiquesRepository.java`, `LieuxRepository.java` — `findAllByOrderByLibAsc()`

## Developer Notes
- **Status**: Fully implemented
- @PreAuthorize correctly applied: POST/PUT/DELETE restricted to SUPER_ADMIN
- GET endpoints are public per spec — but SecurityConfig blocks them. Fix needed: add permitAll for GET /api/caracteristiques and GET /api/lieux.
- Alphabetical sorting via `findAllByOrderByLibAsc()` repository method
- Simple DTO: { id, lib }

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
