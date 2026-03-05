# Base layout (sidebar, footer, responsive)
> Spec ID: fe-layout | Category: layout | Status: COMPLETE

## Implementation

### Files
- Template: `templates/base.html.twig`
- Controller: none (inherited by all templates)
- API methods: none (uses session data)

### What Exists
- **Sidebar layout** (240px fixed left, replaces former top navbar)
  - Brand header: Horoazhon logo + name
  - Agency badge (if user belongs to an agency with logo)
  - Role-adaptive navigation sections with active link highlighting
  - User footer: avatar initial, name, role label, logout button
  - Login button for unauthenticated users
- **Sidebar sections by role:**
  - Unauthenticated: Accueil, Biens, Agences + "Se connecter" button
  - CLIENT: + Tableau de bord, Mes contrats, Mes biens, Mon profil
  - AGENT: + Admin section (Tableau de bord, Biens, Contrats, Personnes, Mon profil)
  - ADMIN_AGENCY: + Utilisateurs, Parametres agence
  - SUPER_ADMIN: + Agences, Donnees de reference
- **Active link detection** via Twig route matching (`starts with` for prefix groups)
- **Mobile responsive** (<768px): sidebar hidden, hamburger toggle (fixed top-left), slide-out drawer with dark overlay, Escape key closes
- **Footer** inside main content area with copyright and links
- **Flash messages** (success/error) with dismiss buttons and entrance animation
- **Anti-AI-slop design**: system font stack (no Inter), varied border-radius (4/6/8/10px), left-aligned layout
- All global CSS (~460 lines inline)

### What's Missing
Nothing — sidebar layout is complete.

## Remarks

### Developer Notes
- All templates extend `base.html.twig` directly (no separate admin base template)
- Auth pages override `.container` styles to hide footer and go full-width
- System font stack uses SF Pro (macOS), Segoe UI (Windows), Roboto (Android)
- Mobile sidebar uses `transform: translateX(-100%)` with 0.25s transition
- Body overflow set to hidden when mobile sidebar is open (prevents scroll-behind)
- Active link uses `border-left: 3px solid #2563eb` + blue-50 background

### QA Remarks
- **Test coverage**: Sidebar visible, role-adaptive links (test each role), mobile hamburger toggle, footer, flash messages, active link highlighting
- **UX proposal (per user feedback)**: Add "Mon espace" / personal dashboard link for ALL authenticated roles (not just CLIENT). AGENT and ADMIN_AGENCY who own properties should see their portfolio too.
- **Edge case**: Very long user name in sidebar footer — verify truncation works
- **Edge case**: Very long agency name in sidebar badge — verify it wraps or truncates
- **Accessibility**: Verify Escape key closes mobile sidebar, hamburger button has aria-label, sidebar uses nav landmark

### Security Remarks
_None yet (Phase 2)_
