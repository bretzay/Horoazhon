# User profile page
> Spec ID: fe-user-profile | Category: profil | Status: COMPLETE

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
Nothing — feature is complete. Password change section, account info display (email, role, agency) are all implemented.

## Remarks

### Developer Notes
- Password change is blocked by backend: the DTO exists (`ChangePasswordRequest.java`) but no corresponding API client method or controller integration
- Profile uses `updatePersonne()` — edits the Personne entity, not the Compte (user account) entity
- This means email/password changes require separate Compte endpoints

### QA Remarks
- ~~**Gap (HIGH)**: Password change section missing~~ — **RESOLVED**: `changePassword()` API method, controller route, and template form all exist.
- ~~**Gap (MEDIUM)**: Email/role/agency not displayed~~ — **RESOLVED**: Account info card shows email, role badge, and agency. Email was missing from session — fixed by storing `$email` from login form input in AuthController.
- **Test coverage**: Page loads for authenticated users, form shows personal info, edit and save works, unauthenticated redirect to /login
- **Edge case**: User without linked personneId — verify redirect to dashboard instead of error page
- **Edge case**: Session sync after profile update — verify sidebar shows updated name

### Security Remarks
_None yet (Phase 2)_
