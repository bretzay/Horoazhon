# Public agency listing and detail
> Spec ID: fe-public-agence | Category: public | Status: PARTIAL

## Implementation

### Files
- Template: `templates/agence/profile.html.twig`
- Controller: `Controller/AgencePublicController.php` → route: `agence_profile` (GET)
- API methods: `getAgenceById(id)`, `getAgenceBiens(id, page, size)`

### What Exists
- Agency detail/profile page at `/agences/{id}`
- Agency info: logo, name, address, contact details
- Paginated property list for the agency (12 per page)
- Public access, no auth required

### What's Missing
- **`/agences` list page**: No route or template for listing all agencies. Only individual agency profiles exist via `/agences/{id}`.
- AgencePublicController has only 1 route (`agence_profile`), needs a `agences_list` route
- Template `templates/agence/list.html.twig` does not exist

## Remarks

### Developer Notes
- The agency list page is referenced in navbar links and homepage but has no implementation
- Backend `GET /api/agences` endpoint exists and returns all agencies — frontend just needs the page
- Navbar currently links to `/biens` only; `/agences` link will be needed when list page is built

### QA Remarks
- **Blocker (HIGH)**: `/agences` list page is MISSING — no route, no template. Only individual agency profiles at `/agences/{id}` exist. This is a gap: navbar references the page but it doesn't exist. Must be implemented by Frontend Web role.
- **Test coverage**: Detail page loads, shows agency info and properties, handles agency with no properties
- **Edge case**: Agency with no logo — verify placeholder is shown
- **Note**: Cannot test list page until it's implemented. Tests for list page should be marked as expected-failing.

### Security Remarks
_None yet (Phase 2)_
