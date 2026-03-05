# Client dashboard API
> Spec ID: be-client-dashboard | Category: client | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/ClientDashboardController.java`
- Service: `backend/src/main/java/com/realestate/api/service/ClientDashboardService.java`
- DTO: `ClientDashboardDTO.java`

### What Exists
- GET /api/client/dashboard — CLIENT only (@PreAuthorize at class level)
- GET /api/client/contrats — CLIENT's contracts via cosigner relation
- GET /api/client/biens — CLIENT's properties via ownership relation
- Response: ClientDashboardDTO { personneId, totalProperties, totalContracts, activeContracts, totalRevenue, monthlyRevenue, revenueByMonth }

### What's Missing
- **UX proposal**: Consider extending these endpoints to all authenticated roles (not just CLIENT) so AGENT/ADMIN_AGENCY can also see their personal portfolio. Currently restricted by @PreAuthorize to CLIENT only.

## Remarks

### Developer Notes
- **Authorization**: Class-level `@PreAuthorize("hasRole('CLIENT')")` on `ClientDashboardController`. Only CLIENT role can access. SA/AA/AGENT → 403.
- **PersonneId resolution**: `getPersonneId(authentication)` loads Compte from DB, checks `compte.getPersonne() != null`. If no linked Personne, throws `IllegalStateException("No person linked to this account")` → 409 via GlobalExceptionHandler.
- **Dashboard** (`GET /api/client/dashboard`): Returns `ClientDashboardDTO` with:
  - `totalProperties`: Count of properties owned (via Posseder)
  - `totalContracts`: All contracts where person is a cosigner
  - `activeContracts`: Count of EN_COURS + SIGNE contracts
  - Revenue calculations (see below)
  - `recentContracts`: Last 5 contracts sorted by dateCreation DESC
  - `properties`: All owned properties
- **Revenue calculation**: Only counts SIGNE and TERMINE rental contracts where the person is OWNER cosigner type. Ignores EN_COURS (not yet signed) and ANNULE (cancelled).
  - **Fixed-duration contracts** (dureeMois > 0): Generates revenue month-by-month from signature date. For SIGNE contracts, revenue stops at current month. For TERMINE, stops at termination date (dateModification).
  - **Indefinite contracts** (dureeMois=null): Generates revenue from start to endBoundary (current month for SIGNE, termination date for TERMINE).
  - **Monthly revenue**: Sum of mensualite for all currently-active SIGNE contracts.
  - **Signature date**: Uses the latest cosigner dateSignature, or falls back to contrat.dateCreation.
- **Sub-endpoints**: `GET /api/client/contrats` — paginated, `GET /api/client/biens` — paginated. Both use personneId from the authenticated account.
- **No CLIENT account in seed data**: V2 test data has no CLIENT role accounts, so these endpoints can't be tested without creating one first (via invite-client flow).

### QA Remarks
- **Test coverage**: 6 suites — all non-CLIENT roles getting 403 (SUPER_ADMIN, ADMIN_AGENCY, AGENT), unauthenticated, contrats forbidden, biens forbidden
- **Blocker**: Cannot test happy path — no CLIENT account in seed data. Tests only verify non-CLIENT roles are blocked.
- **UX proposal (per user feedback)**: AGENT and ADMIN_AGENCY should also access personal dashboard. Consider removing CLIENT-only restriction or creating parallel endpoints.
- **Edge case**: CLIENT with no linked personne — should return empty data or error?
- **Edge case**: Revenue calculations — verify accuracy with mixed contract types

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
