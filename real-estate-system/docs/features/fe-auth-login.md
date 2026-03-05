# Login page
> Spec ID: fe-auth-login | Category: auth | Status: COMPLETE

## Implementation

### Files
- Template: `templates/auth/login.html.twig`
- Controller: `Controller/AuthController.php` → routes: `login` (GET/POST)
- API methods: `login(email, password)`

### What Exists
- Full-page centered card layout with decorative gradient background
- Email + password form fields with validation
- Role-based redirect: CLIENT → `/client`, others → `/admin`
- Multi-agency selector (hidden by default, shown when API returns agencies list without token)
- Session stores: jwt_token, user_role, user object (nom, prenom, role, agenceId, agenceNom, agenceLogo, personneId)
- "Mot de passe oublie ?" link to `/forgot-password`
- Password minimum 6 characters validation
- Flash messages for errors

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Anti-enumeration: login error message is generic ("Identifiants incorrects")
- Agency selector pre-built for multi-agency login (backend future feature)
- Auth pages hide footer via `.container:has(.login-page) ~ .site-footer { display: none }`

### QA Remarks
- **Test coverage**: Valid login for each role (SUPER_ADMIN, ADMIN_AGENCY, AGENT), invalid credentials, empty form submission
- **UX concern**: No "remember me" checkbox — users must re-login every time the session expires. Consider adding persistent session option.
- **UX concern**: No loading state on submit button — user can double-click and trigger multiple login requests. Recommend disabling button on submit.
- **Edge case**: Multi-agency selector is pre-built but backend doesn't support it yet. Verify selector stays hidden for single-agency users.
- **Accessibility**: Verify form labels are properly associated with inputs (for screen readers)

### Security Remarks
_None yet (Phase 2)_
