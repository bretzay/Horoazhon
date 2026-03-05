# Admin property pages (list, create, edit)
> Spec ID: fe-admin-bien | Category: admin | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/admin/bien/list.html.twig`, `templates/admin/bien/form.html.twig`
- Controller: `Controller/AdminBienController.php` → routes: `admin_biens` (GET), `admin_biens_new` (GET/POST), `admin_biens_edit` (GET/POST), `admin_biens_delete` (POST)
- API methods: `getBiens()`, `getBienById()`, `createBien()`, `updateBien()`, `deleteBien()`, `setBienProprietaire()`, `removeBienProprietaire()`, `createAchat()`, `updateAchat()`, `deleteAchat()`, `createLocation()`, `updateLocation()`, `deleteLocation()`, `addBienCaracteristique()`, `removeBienCaracteristique()`, `addBienLieu()`, `removeBienLieu()`, `addBienPhoto()`, `removeBienPhoto()`

### What Exists
- List page: table with summary stat cards, search/filter bar, pagination (20 per page)
- Create form: basic property fields + agency dropdown (SUPER_ADMIN only)
- Edit form: multi-tab management (info, sales listing, rental listing, characteristics, proximity, owner, photos)
- Photo upload to `/public/uploads/photos` with auto-generated filenames
- Sales listing (Achat) and rental listing (Location) inline management
- Characteristics and proximity locations add/remove
- Owner/proprietaire assignment from personne dropdown
- CLIENT role: can only edit properties they own
- Delete confirmation

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Multi-action form: uses `_action` parameter to route to different handlers (save info, add achat, add location, etc.)
- Property creation is two-step: create bien first, then set proprietaire in separate API call
- Agency auto-assigned for non-SUPER_ADMIN users from session

### QA Remarks
- **UX concern (HIGH)**: Multi-tab edit form with `_action` parameter routing is complex — verify all tab actions (save info, add achat, add location, add characteristic, add lieu, set owner, add photo) work correctly and don't conflict.
- **UX concern (MEDIUM)**: Photo upload stores to `/public/uploads/photos` with auto-generated filenames — no visible progress indicator for large uploads. Consider adding upload progress feedback.
- **Test coverage**: Create property form, edit tabs, photo upload/remove, characteristic/lieu add/remove, owner assignment, delete confirmation, CLIENT role limited access
- **Edge case**: Creating a property and then immediately trying to edit sub-resources — verify the redirect chain works (create → redirect to edit page with tabs).
- **Edge case**: Deleting a property with active contracts should fail — verify error message is shown.

### Security Remarks
_None yet (Phase 2)_
