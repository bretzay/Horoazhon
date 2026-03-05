# Password reset flow (forgot + reset pages)
> Spec ID: fe-auth-password-reset | Category: auth | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/auth/forgot-password.html.twig`, `templates/auth/reset-password.html.twig`
- Controller: `Controller/AuthController.php` → routes: `forgot_password` (GET/POST), `reset_password` (GET/POST)
- API methods: `requestPasswordReset(email)`, `checkResetToken(token)`, `resetPassword(token, password)`

### What Exists
- Forgot password: email form, always shows success message (anti-enumeration)
- Reset password: token validation on load, password + confirmation form
- Three states on reset page: invalid/expired token, form, success
- Back link to `/login` on forgot password page
- Success message with link to `/login` on reset page
- Same full-page centered card layout as login/activate

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Anti-enumeration: forgot password always says "Email envoye si le compte existe" regardless of whether email is found
- Reset token validation uses `checkResetToken()` on page load
- Both pages accessible while logged in (no redirect guard)

### QA Remarks
- **UX concern (MEDIUM)**: Both forgot-password and reset-password pages are accessible while logged in (no redirect guard). Logged-in users should probably be redirected to /profil where they can change password directly.
- **Test coverage**: Forgot page form submission shows success message, reset page with invalid token shows error, reset page with no token parameter
- **Edge case**: User submits forgot-password multiple times — does each request invalidate the previous token? If so, only the last link works. Verify this behavior.
- **Accessibility**: Success/error messages should have proper ARIA roles (role="alert").

### Security Remarks
_None yet (Phase 2)_
