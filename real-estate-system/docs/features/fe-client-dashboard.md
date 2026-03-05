# Client dashboard
> Spec ID: fe-client-dashboard | Category: client | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/client/dashboard.html.twig`, `templates/client/contrats.html.twig`, `templates/client/biens.html.twig`
- Controller: `Controller/ClientDashboardController.php` → routes: `client_dashboard` (GET), `client_contrats` (GET), `client_biens` (GET)
- API methods: `getClientDashboard()`, `getClientContrats(page, size)`, `getClientBiens(page, size)`

### What Exists
- Dashboard with welcome message and summary stats
- Contracts page: paginated list (10 per page) of client's own contracts
- Properties page: paginated list (10 per page) of client's associated properties
- Graceful error handling: shows flash message, provides empty data fallback
- Uses `/api/client/*` dedicated endpoints (not generic endpoints with filters)

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- All endpoints default to page 0 with size=10
- Client sees only own data — filtered server-side by personneId from JWT
- Dashboard, contrats, biens are separate routes (not tabs on one page)

### QA Remarks
- **Blocker for testing**: No CLIENT test account in seed data — must create one via invite+activation flow before testing. Consider adding a CLIENT account to V2 migration for testing convenience.
- **UX proposal (HIGH)**: AGENT and ADMIN_AGENCY users who own properties should also have access to a personal dashboard ("Mon espace") to view their own contracts and properties — just like CLIENT users. Currently /client/* endpoints are restricted to CLIENT role only, but staff members can also be property owners. Proposal: either extend /client/* to accept all authenticated roles (scoped to their personneId), or add a separate "my portfolio" section in the admin sidebar. A navbar item "Mon espace" should be visible for all authenticated users.
- **UX concern (LOW)**: Dashboard, contrats, biens are separate routes — navigation between them requires page reloads. Consider tab-based layout for smoother UX.
- **Test coverage**: Dashboard loads for CLIENT, shows correct stats, contracts list paginated, properties list paginated
- **Edge case**: New client with zero contracts/properties — verify empty state messages are shown instead of errors
- **Access control**: Currently SUPER_ADMIN/ADMIN_AGENCY/AGENT get 403 on /client routes — this should change per the UX proposal above

### Security Remarks
_None yet (Phase 2)_
