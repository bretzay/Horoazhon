# be-contrat-lifecycle — Contract workflow, documents, and expiration

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/ContratController.java`
- **Service**: `backend/src/main/java/com/realestate/api/service/ContratService.java`
  - `updateStatut` (line 103-139)
  - `confirmContrat` (line 317-354)
  - `cancelContrat` (line 356-367)
  - `setDocumentSigne` (line 369-382)
  - `handlePurchaseCompletion` (line 149-250) — ownership transfer + reconduction
  - `createReconductionContract` (line 261-315) — auto-creates rental contract with new owner
- **Scheduler**: `backend/src/main/java/com/realestate/api/service/ContratExpirationScheduler.java`
- **PDF**: `backend/src/main/java/com/realestate/api/service/ContratPdfService.java`

## Developer Notes
- **Status**: Fully implemented
- State machine enforced: EN_COURS → SIGNE (via confirm), EN_COURS → ANNULE (via cancel), SIGNE → TERMINE
- TERMINE is frozen — no further modifications
- Confirm requires signed document uploaded first, sets cosigner dateSignature, cancels sibling EN_COURS contracts
- Purchase completion (ACHAT→TERMINE): ownership transfer, rental reconduction, sibling cancellation, achat unlink
- Expiration scheduler: daily at 2:00 AM, finds SIGNE rentals past dureeMois, transitions to TERMINE
- Document management: upload/download/delete with status guards
- PDF generation via Apache PDFBox

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
