# Contract workflow, documents, and expiration
> Spec ID: be-contrat-lifecycle | Category: contrat | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/ContratController.java` → PATCH, POST (confirm/cancel/expire-check), GET/POST/DELETE (documents)
- Services: `ContratService.java`, `ContratPdfService.java`, `ContratExpirationScheduler.java`

### What Exists
- Status transitions: EN_COURS → SIGNE (confirm), EN_COURS → ANNULE (cancel), SIGNE → TERMINE (PATCH)
- Confirm side effects: sets cosigner dateSignature, auto-cancels sibling EN_COURS contracts
- Purchase completion (ACHAT TERMINE): ownership transfer, rental reconduction, EN_COURS cancellation
- PDF generation (Apache PDFBox)
- Signed document upload/download/delete (multipart)
- Expiration scheduler: daily cron at 2:00 AM, manual trigger via POST /api/contrats/expire-check

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize` on ContratController (SA, AA, AGENT). `expire-check` endpoint additionally requires `ROLE_SUPER_ADMIN` only.
- **State machine** (via `updateStatut`):
  - TERMINE → any change: blocked ("contrat termine ne peut plus etre modifie") → 400
  - SIGNE → only TERMINE allowed → 400 otherwise
  - SIGNE/TERMINE transitions require `documentSigne` to be non-null/non-blank → 400 otherwise
  - EN_COURS → SIGNE/TERMINE: not allowed via `updateStatut` (use `confirmContrat` for EN_COURS→SIGNE)
  - EN_COURS ← SIGNE/TERMINE: blocked ("impossible de revenir en EN_COURS") → 400
- **Confirm** (`POST /{id}/confirm`): EN_COURS → SIGNE. Requires uploaded signed document. Sets `dateSignature` on ALL cosigners to `now()`. Then auto-cancels ALL sibling EN_COURS contracts on the same offer (location or achat).
- **Cancel** (`POST /{id}/cancel`): Only EN_COURS contracts can be cancelled → ANNULE. SIGNE/TERMINE → 400.
- **Purchase completion** (ACHAT contract → TERMINE via `updateStatut`): Triggers `handlePurchaseCompletion()`:
  1. Transfers ownership to BUYER cosigner (deletes all existing owners, creates new Posseder)
  2. Terminates active SIGNE rental contracts on same bien, creates reconduction contracts with new owner (SIGNE status, auto-generated PDF)
  3. Cancels EN_COURS rental contracts on same bien
  4. If no active rental existed, unlinks Location from bien
  5. Cancels sibling EN_COURS purchase contracts on same Achat
  6. Unlinks Achat from bien
- **Reconduction contract**: Auto-created with SIGNE status, buyer as OWNER, renter as RENTER, auto-generated PDF (old contract doc + reconduction note page). If PDF generation fails, contract is still created but without document.
- **Signed document upload**: Only accepts `application/pdf`. Saves to `./uploads/contrats/contrat-{id}-signe.pdf`. Blocked on SIGNE and TERMINE contracts (`setDocumentSigne` checks status).
- **Expiration scheduler**: `@Scheduled(cron = "0 0 2 * * *")` + runs on startup. Finds SIGNE rental contracts, calculates end date from latest cosigner signature + dureeMois. **Skips null/0 dureeMois** (indefinite contracts). Sets expired contracts to TERMINE.
- **Error handling**: `IllegalArgumentException` → 400, `EntityNotFoundException` → 404, `IllegalStateException` → 409.

### QA Remarks
- **Test coverage**: 7 suites — cancel, PDF generation, PDF 404, signed doc not found, unauthenticated, expire-check SUPER_ADMIN, expire-check forbidden
- **Complex business logic**: Confirm side effects (sibling cancellation, ownership transfer) — highest risk area for bugs
- **Edge case**: Confirm without uploaded signed document — should return error
- **Edge case**: Cancel already-SIGNE contract — should return error
- **Edge case**: Upload signed doc to SIGNE/TERMINE contract — should be blocked
- **Edge case**: Expiration of contract with null/0 dureeMois — should be skipped (indefinite)
- **Missing tests**: Full confirm flow with sibling cancellation, purchase completion with ownership transfer

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
