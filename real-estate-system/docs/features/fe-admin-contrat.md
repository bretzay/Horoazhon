# Admin contract pages (list, create, detail)
> Spec ID: fe-admin-contrat | Category: admin | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/admin/contrat/list.html.twig`, `templates/admin/contrat/form.html.twig`, `templates/admin/contrat/detail.html.twig`
- Controller: `Controller/AdminContratController.php` → routes: `admin_contrats` (GET), `admin_contrats_new` (GET/POST), `admin_contrats_detail` (GET), `admin_contrats_statut` (POST), `admin_contrats_confirm` (POST), `admin_contrats_cancel` (POST), `admin_contrats_pdf` (GET), `admin_contrats_upload_signe` (POST), `admin_contrats_delete_signe` (POST), `admin_contrats_signed_pdf` (GET)
- API methods: `getContrats()`, `getContratById()`, `createContrat()`, `updateContratStatut()`, `confirmContrat()`, `cancelContrat()`, `getContratPdf()`, `uploadContratSignedPdf()`, `deleteContratSignedPdf()`, `getContratSignedPdf()`, `getAchats()`, `getLocations()`, `getBienById()`

### What Exists
- List page: paginated table (20 per page), ID/type/bien/client/dates/status/montant columns
- Create form: type selection (Location/Achat listing), auto-resolves property owner, cosigners with roles
- Detail page: full contract info, cosigners, status badge, PDF download, signed PDF upload/download/delete
- Status management: confirm, cancel actions (admin/agent only)
- Preselection support: `?achatId=X` or `?locationId=X` query params
- CLIENT role blocked from confirm/cancel/delete actions

### What's Missing
- List page lacks filter controls (type, status, date range)
- List shows raw IDs instead of formatted CTR-{id} in some places

## Remarks

### Developer Notes
- Contract creation auto-resolves owner from selected listing (Location or Achat)
- Cosigners structure: array with personneId + typeSignataire (OWNER, SELLER, RENTER, BUYER)
- PDF generation is server-side; signed PDF is uploaded as multipart form
- Role enforcement: CLIENT sees error "Vous n'avez pas les droits..." on restricted actions

### QA Remarks
- **UX gap (HIGH)**: List page lacks filter controls (type, status, date range) — noted as missing. Users managing many contracts will struggle without filters. Propose implementation.
- **UX gap (MEDIUM)**: Raw IDs shown instead of formatted CTR-{id} — inconsistent with convention documented in CLAUDE.md.
- **Test coverage**: Create flow with cosigners, confirm/cancel status transitions, PDF generation, signed document upload/download/delete
- **Edge case**: What happens when confirming a contract that has sibling EN_COURS contracts on same offer? Must verify auto-cancellation works.
- **Edge case**: Upload signed PDF to already-SIGNE contract should be blocked — verify error handling.
- **Accessibility**: Status badges should use aria-labels, not just color, to convey meaning.

### Security Remarks
_None yet (Phase 2)_
