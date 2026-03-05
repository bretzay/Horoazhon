# Admin dashboard
> Spec ID: fe-admin-dashboard | Category: admin | Status: COMPLETE

## Implementation

### Files
- Template: `templates/admin/dashboard.html.twig`
- Controller: `Controller/AdminDashboardController.php` → route: `admin_dashboard` (GET)
- API methods: `getBiens(filters)`, `getAgences()`, `getPersonnes()`, `getContrats(filters)`

### What Exists
- Statistics cards: biens count, agences count, personnes count, contrats count
- Stat cards with colored left borders (V0-style design)
- Quick access links to admin sections
- Role-scoped data (fetches size=1 to get totalElements counts)
- CLIENT role redirected to `/client`
- Unauthenticated redirected to `/login`

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Lightweight data fetching: only page=0 size=1 to get totals, avoids loading full datasets
- Dashboard does not yet show "recent activity" tables (could be a future enhancement)
- Stat card design uses 4 color variants from DESIGN_SYSTEM.md

### QA Remarks
- **Test coverage**: Page loads for SUPER_ADMIN/ADMIN_AGENCY/AGENT, stat cards show counts, quick access links work, CLIENT redirected to /client, unauthenticated redirected to /login
- **UX concern (MEDIUM)**: No "recent activity" tables — dashboard is just stat cards. Users may expect to see recent contracts, recent properties added. Consider adding.
- **Edge case**: New agency with zero data — verify all stat cards show 0, not errors
- **Performance note**: Uses size=1 queries to get totals — efficient but verify totalElements is accurate

### Security Remarks
_None yet (Phase 2)_
