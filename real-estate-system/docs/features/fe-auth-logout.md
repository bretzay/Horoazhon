# Logout
> Spec ID: fe-auth-logout | Category: auth | Status: COMPLETE

## Implementation

### Files
- Template: none (redirect only)
- Controller: `Controller/AuthController.php` → route: `logout` (GET)
- API methods: none (session-only operation)

### What Exists
- Clears jwt_token, user_role, user from session
- Invalidates PHP session
- Redirects to `/login`
- Works whether user is authenticated or not

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- No API call needed — logout is purely a session operation
- Calling `/logout` when not logged in silently redirects to `/login`

### QA Remarks
- **Test coverage**: Login then logout redirects to /login, unauthenticated /logout redirects to /login
- **Edge case**: Verify session is fully cleared — after logout, navigating to /admin should redirect to /login (not serve cached page)
- **UX note**: No "Are you sure?" confirmation on logout. Acceptable for now but could be annoying if accidental.

### Security Remarks
_None yet (Phase 2)_
