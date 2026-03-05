# Account activation page
> Spec ID: fe-auth-activate | Category: auth | Status: COMPLETE

## Implementation

### Files
- Template: `templates/auth/activate.html.twig`
- Controller: `Controller/AuthController.php` → route: `activate_account` (GET/POST)
- API methods: `checkActivationToken(token)`, `activateAccount(token, password)`

### What Exists
- Token validation on page load via `checkActivationToken()`
- Three UI states: invalid token, password form, success message
- Password + confirmation form with client-side match validation
- Minimum 6 character password requirement
- Success message with link to `/login`
- Same full-page centered card layout as login
- Horoazhon branding above the card

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Token is single-use: refreshing after activation shows invalid token state
- No token parameter = invalid token state shown immediately

### QA Remarks
- **UX concern (MEDIUM)**: No password strength indicator — users don't know if their 6-character password is weak. Consider adding a visual strength meter.
- **UX concern (LOW)**: After successful activation, user must navigate to /login manually. Consider auto-redirecting after 3 seconds.
- **Test coverage**: Invalid token page, valid form submission (via manual token creation in seed data if possible), password mismatch client-side validation, no token parameter
- **Edge case**: What happens if user bookmarks the activation URL and returns after token expires? Verify expired token message is clear and actionable (contact admin).

### Security Remarks
_None yet (Phase 2)_
