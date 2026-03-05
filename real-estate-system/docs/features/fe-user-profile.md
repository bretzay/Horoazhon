# User profile page
> Spec ID: fe-user-profile | Category: profil | Status: PARTIAL

## Implementation

### Files
- Template: `templates/profil/index.html.twig`
- Controller: `Controller/ProfileController.php` → route: `profil` (GET/POST)
- API methods: `getPersonneById(personneId)`, `updatePersonne(personneId, data)`

### What Exists
- Profile display and edit form: nom, prenom, dateNais, rue, ville, codePostal, rib
- Session sync: updates nom/prenom in session after save
- Requires personneId in session (redirects to dashboard if missing)
- Role-based redirect on no-personneId: CLIENT → `/client`, others → `/admin`

### What's Missing
- **Password change section**: No `changePassword()` method in API client. Backend DTO (`ChangePasswordRequest.java`) exists but endpoint is not wired to frontend.
- Email displayed as read-only (correct behavior, but not currently shown)
- Role and agency shown as read-only (not currently displayed)

## Remarks

### Developer Notes
- Password change is blocked by backend: the DTO exists (`ChangePasswordRequest.java`) but no corresponding API client method or controller integration
- Profile uses `updatePersonne()` — edits the Personne entity, not the Compte (user account) entity
- This means email/password changes require separate Compte endpoints

### QA Remarks
- **Gap (HIGH)**: Password change section is missing — backend DTO exists but no frontend integration. This is a Phase 1 completion gap. Must be wired before Phase 2 audit can pass.
- **Gap (MEDIUM)**: Email, role, and agency not displayed as read-only — users have no way to see their account info on the profile page (only personal info from Personne entity).
- **Test coverage**: Page loads for authenticated users, form shows personal info, edit and save works, unauthenticated redirect to /login
- **Edge case**: User without linked personneId — verify redirect to dashboard instead of error page
- **Edge case**: Session sync after profile update — verify sidebar shows updated name

### Security Remarks
_None yet (Phase 2)_
