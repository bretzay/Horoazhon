# Admin person pages (list, create, edit)
> Spec ID: fe-admin-personne | Category: admin | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/admin/personne/list.html.twig`, `templates/admin/personne/form.html.twig`
- Controller: `Controller/AdminPersonneController.php` → routes: `admin_personnes` (GET), `admin_personnes_search_json` (GET), `admin_personnes_new` (GET/POST), `admin_personnes_edit` (GET/POST), `admin_personnes_invite` (POST), `admin_personnes_delete` (POST)
- API methods: `getPersonnes()`, `searchPersonnes()`, `getPersonneById()`, `createPersonne()`, `updatePersonne()`, `deletePersonne()`, `getPersonneAccountStatus()`, `getPersonneBiens()`, `getPersonneContrats()`, `inviteClient()`

### What Exists
- List page: table with name, email, telephone columns; search by name/email
- JSON search endpoint for autocomplete (`/admin/personnes/search.json?q=...`)
- Create/edit form: nom, prenom, dateNais, rue, ville, codePostal, rib
- Edit page shows: owned properties, signed contracts, account status
- Invite button sends account activation email (shows activation URL in flash)
- Delete confirmation

### What's Missing
- List page has no pagination — all personnes loaded at once

## Remarks

### Developer Notes
- Search JSON endpoint requires q >= 1 character
- Account status check is optional (gracefully skips if endpoint fails)
- Invitation creates account with activation token; frontend shows `/activate?token=X` in flash message
- Person form does not include type dropdown (client/proprietaire) — type is determined by relationships

### QA Remarks
- **UX gap (HIGH)**: No pagination on person list — all loaded at once. This will cause performance issues with many records. Propose pagination implementation.
- **UX concern (MEDIUM)**: No explicit "type" field (client/proprietaire) on form — type determined by relationships. This may confuse admins who expect to set it explicitly.
- **Test coverage**: List, search, create, edit, delete, invite flow, account status display
- **Edge case**: Search JSON endpoint for autocomplete — test with special characters, accents (é, è, ê), and empty query
- **Edge case**: Deleting a person linked to active contracts — verify error message explains why deletion is blocked

### Security Remarks
_None yet (Phase 2)_
