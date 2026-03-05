# be-personne — Person operations

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/PersonneController.java`
- **Service**: `backend/src/main/java/com/realestate/api/service/PersonneService.java`
  - `findAll` (line 26-30)
  - `search` (line 40-43)
  - `findById`, `create`, `update`, `delete`
  - Sub-resources: `findBiensByPersonne`, `findContratsByPersonne`
- **Repository**: `backend/src/main/java/com/realestate/api/repository/PersonneRepository.java`
  - Has `findByAgence()` and `searchByAgence()` methods (agency-filtered)

## Developer Notes
- **Status**: Fully implemented with one gap
- **GAP**: `findAll()` calls `personneRepository.findAll()` with NO agency isolation — returns ALL persons across all agencies. Repository already has `findByAgence(agenceId, pageable)` method but service doesn't use it.
- **GAP**: `search()` calls `searchByNameIgnoreAccents()` with NO agency isolation — repository has `searchByAgence(agenceId, searchTerm)` but service doesn't use it.
- Fix: inject SecurityUtils, check if authenticated and agenceId != null, use agency-filtered repo methods
- Sub-resources (biens, contrats) work correctly
- Search uses native SQL with Latin1_General_CI_AI collation for accent-insensitive matching

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
