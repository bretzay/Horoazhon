# be-contrat-create — Contract creation

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/ContratController.java`
- **Service**: `backend/src/main/java/com/realestate/api/service/ContratService.java`
  - `create` (line 59-101)
- **DTO**: `CreateContratRequest.java`, `CosignerRequest.java`
- **Entity**: `Contrat.java`, `Cosigner.java`

## Developer Notes
- **Status**: Fully implemented with one fix needed
- **GAP**: Line 60 enforces `cosigners.size() != 2` (exactly 2). Spec says "at least 2 cosigners". Must change to `cosigners.size() < 2`.
- Mutually exclusive locationId/achatId validation works (line 64-67)
- Default status: EN_COURS
- createdBy set to current authenticated user
- Cosigners created via cascade with contrat save
- TypeSignataire: BUYER, SELLER, RENTER, OWNER (English enum values)

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
