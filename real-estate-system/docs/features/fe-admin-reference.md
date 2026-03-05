# Admin reference data page
> Spec ID: fe-admin-reference | Category: admin | Status: COMPLETE

## Implementation

### Files
- Template: `templates/admin/reference/index.html.twig`
- Controller: `Controller/AdminReferenceController.php` → routes: `admin_references` (GET), `admin_ref_carac_add` (POST), `admin_ref_carac_edit` (POST), `admin_ref_carac_delete` (POST), `admin_ref_lieu_add` (POST), `admin_ref_lieu_edit` (POST), `admin_ref_lieu_delete` (POST)
- API methods: `getCaracteristiques()`, `createCaracteristique()`, `updateCaracteristique()`, `deleteCaracteristique()`, `getLieux()`, `createLieu()`, `updateLieu()`, `deleteLieu()`

### What Exists
- Single page with two sections: Caracteristiques and Lieux
- Inline CRUD: add/edit/delete without leaving the page
- SUPER_ADMIN only: all routes guarded with `requireSuperAdmin()` check
- Simple field: `lib` (libelle/label) for both entity types

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- All operations happen inline on the same page (no separate forms or modals)
- Only field is `lib` — kept intentionally simple for reference data
- Guard: `requireSuperAdmin()` throws exception for non-SUPER_ADMIN roles

### QA Remarks
- **Test coverage**: Page loads for SUPER_ADMIN, both sections visible, add/edit/delete inline operations, non-SUPER_ADMIN blocked
- **Edge case**: Delete a characteristic that's in use by existing properties — verify error handling
- **Edge case**: Empty lib field — verify validation prevents empty reference data creation
- **Edge case**: Very long lib value — verify display doesn't break layout

### Security Remarks
_None yet (Phase 2)_
