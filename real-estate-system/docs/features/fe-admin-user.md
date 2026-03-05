# Admin user pages (list, create)
> Spec ID: fe-admin-user | Category: admin | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/admin/user/list.html.twig`, `templates/admin/user/form.html.twig`
- Controller: `Controller/AdminUserController.php` → routes: `admin_utilisateurs` (GET), `admin_utilisateurs_new` (GET/POST), `admin_utilisateurs_deactivate` (POST), `admin_utilisateurs_reactivate` (POST)
- API methods: `getUsers(page, size)`, `createUser(data)`, `deactivateUser(id)`, `reactivateUser(id)`

### What Exists
- List page: paginated table (20 per page) with email, nom, prenom, role badge, status
- Create form: email, nom, prenom, dateNais, role dropdown
- SUPER_ADMIN: can assign agenceId during creation
- Activation: returns token, frontend shows `/activate?token=X` in flash message
- Deactivate/reactivate actions per user
- Role dropdown populated from enum values

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- No edit form for existing users — only create, deactivate, reactivate
- ADMIN_AGENCY can only create AGENT and CLIENT roles
- Activation URL shown in flash message for manual distribution (no email service in frontend)

### QA Remarks
- **UX concern (HIGH)**: Activation URL shown in flash message for manual copy — this is error-prone and not user-friendly. Should auto-copy to clipboard or provide a "Copy" button. Better yet, integrate email service.
- **UX concern (MEDIUM)**: No edit form for existing users — once created, only deactivate/reactivate is possible. Admins may need to change a user's role or reassign agency.
- **Test coverage**: Create user as SUPER_ADMIN with agency selection, create as ADMIN_AGENCY (limited roles), deactivate/reactivate, duplicate email validation
- **Edge case**: Role hierarchy enforcement — ADMIN_AGENCY should not be able to create ADMIN_AGENCY or SUPER_ADMIN accounts. Verify 403 is returned.
- **Edge case**: Attempting to deactivate the last SUPER_ADMIN should fail.

### Security Remarks
_None yet (Phase 2)_
