# be-listing — Rental and sale listing operations

## Codebase Context
- **Controllers**:
  - `backend/src/main/java/com/realestate/api/controller/LocationController.java`
  - `backend/src/main/java/com/realestate/api/controller/AchatController.java`
- **Services**:
  - `backend/src/main/java/com/realestate/api/service/LocationService.java`
  - `backend/src/main/java/com/realestate/api/service/AchatService.java`
- **Entities**: `Location.java` (bien_id UNIQUE), `Achat.java` (bien_id UNIQUE)

## Developer Notes
- **Status**: Partial implementation
- CRUD operations work for both Location and Achat
- Duplicate bien_id → 409 works via IllegalStateException handler in GlobalExceptionHandler
- No role enforcement (no @PreAuthorize) — any authenticated user can manage listings
- **GAP**: Race condition on unique constraint (bien_id) — if two concurrent requests try to create a listing for the same bien, the DB unique constraint throws DataIntegrityViolationException which is not caught by GlobalExceptionHandler. Needs DataIntegrityViolationException handler → 409.
- A property can have both a Location AND an Achat (dual listing)

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
