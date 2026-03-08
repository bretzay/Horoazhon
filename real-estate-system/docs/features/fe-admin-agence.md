# Admin agency pages (list, create, edit, settings)
> Spec ID: fe-admin-agence | Category: admin | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/admin/agence/list.html.twig`, `templates/admin/agence/form.html.twig`, `templates/admin/agence/settings.html.twig`
- Controller: `Controller/AdminAgenceController.php` → routes: `admin_agences` (GET), `admin_agences_new` (GET/POST), `admin_agences_edit` (GET/POST), `admin_agence_settings` (GET/POST), `admin_agences_delete` (POST)
- API methods: `getAgences()`, `getAgenceById()`, `createAgence()`, `updateAgence()`, `deleteAgence()`

### What Exists
- List page: table with agency details (ID, nom, adresse, SIRET, telephone, email)
- Create/edit form: nom, adresse, SIRET, telephone, email fields
- Settings page: agency branding (nom, description, logo upload with 1:1 square center-crop via GD library)
- Logo saved to `/public/uploads/logos` as square PNG
- Session updated after logo/name changes (agenceNom, agenceLogo)
- SUPER_ADMIN sees all agencies; ADMIN_AGENCY sees own only
- Delete action available

### What's Missing
Nothing — feature is complete. New/delete buttons are already SUPER_ADMIN-gated in the template.

## Remarks

### Developer Notes
- Settings page uses GD library for image cropping with fallback to raw upload if GD not available
- Logo upload path: `/public/uploads/logos/{timestamp}_{original}.png`
- SUPER_ADMIN restriction on create/delete should be enforced in template with `{% if user.role == 'SUPER_ADMIN' %}`

### QA Remarks
- ~~**Bug (HIGH)**: New/delete buttons not restricted to SUPER_ADMIN~~ — **RESOLVED**: template already uses `{% if app.session.get('user_role') == 'SUPER_ADMIN' %}` guards on both buttons.
- **Test coverage**: List page, create form (SUPER_ADMIN), edit form, settings page, delete, role restrictions
- **Edge case**: ADMIN_AGENCY accessing another agency's edit page — verify 403 or redirect
- **Edge case**: Logo upload with non-image file — verify server-side validation and error message
- **Edge case**: Delete agency with active contracts — verify error message

### Security Remarks
_None yet (Phase 2)_
