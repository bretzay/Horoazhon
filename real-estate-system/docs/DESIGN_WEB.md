# Design System — Web (Symfony/Twig)

> **Owner**: Role 1 — Frontend Web
> **Parent**: [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md) (shared tokens — read it first)
> **Rule**: Read this file for all web styling decisions. Update it when adding new components or CSS changes.

---

## CSS Architecture

- All global CSS: inline in `base.html.twig` `<style>` block
- Page-specific CSS: `{% block stylesheets %}` per template
- No framework, no build pipeline, no preprocessor, no CSS variables
- Tokens from DESIGN_SYSTEM.md used as raw hex values
- JavaScript: vanilla JS in `{% block javascripts %}`, no framework

### Anti-AI-Slop Rules

These rules prevent the generic "AI-generated" aesthetic:
1. **No Inter font** — use system font stack: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif`
2. **Varied border-radius** — not uniform 16px everywhere. Use 4px (small elements), 6px (buttons/inputs), 8px (tables/filters), 10px (cards/sections), 9999px (badges only)
3. **No excessive centering** — sidebar layout is left-anchored, content left-aligned within main area
4. **No purple gradients** — stick to blue (#2563eb) and slate (#0f172a) palette only

### CDN Dependencies

| Library | CDN | Usage |
|---------|-----|-------|
| Chart.js v4 | cdnjs | Admin dashboard charts only |

### Template Blocks (base.html.twig)

- `{% block title %}` — Page title
- `{% block stylesheets %}` — Page CSS
- `{% block body %}` — Main content
- `{% block javascripts %}` — Page JS

---

## Layout Patterns

| Pattern | Extends | Structure |
|---------|---------|-----------|
| All pages | `base.html.twig` | Sidebar (240px fixed) + main content + footer |
| Auth pages | `base.html.twig` | Sidebar (public links) + full-page centered card, decorative bg, no footer |

All templates extend `base.html.twig` directly — no `base_admin.html.twig`. The sidebar is role-adaptive.

### Container

```css
max-width: 1280px;
padding: space-8 space-6;           /* 32px 24px desktop */
padding: space-5 space-4;           /* 20px 16px mobile, plus 3.5rem top for hamburger clearance */
```

---

## Component Specs

All values use tokens from DESIGN_SYSTEM.md. Refer there for hex codes.

### Sidebar

```
Width: 240px fixed, position fixed, height 100vh, bg white, border-right 1px slate-200
z-index: 1000, overflow-y auto, display flex column

Header: padding space-5, border-bottom 1px slate-100
  Brand: icon 32x32 gradient radius-md, text 17px weight 800 slate-900
  Agency badge (if applicable): slate-50 bg, radius 6px, text-sm weight 600 slate-500

Nav: flex 1, padding space-2 vertical, overflow-y auto
  Sections: separated by 1px slate-100 border-top
  Labels: text 11px weight 600 slate-400 uppercase, letter-spacing 0.5px
  Links: padding space-2 space-5, text 13px weight 500 slate-500
    Icon: 18px, currentColor, opacity 0.7
    border-left: 3px transparent
    Hover: bg slate-50, color slate-900
    Active: bg blue-50, color blue-500, weight 600, border-left blue-500, icon opacity 1

Footer: border-top 1px slate-200, padding space-3 space-5
  User info: avatar 32px radius 6px slate-200 bg, name text 13px weight 600, role text 11px slate-400
  Logout: 32px square radius 6px, hover bg red-100 color red-600
  Login btn (unauthenticated): full-width, blue-500 bg, radius 6px, text 13px weight 600

Mobile (<768px):
  Sidebar: transform translateX(-100%), transition 0.25s
  Open state: translateX(0)
  Toggle: 40x40, fixed top-left, white bg, slate-200 border, radius 6px, z-1001
  Overlay: fixed inset 0, rgba(15,23,42,0.4), z-999
  Body overflow hidden when open
```

### Cards

```css
background: white; border-radius: 10px;
border: 1px solid slate-200; padding: space-6;
transition: box-shadow 0.2s;
:hover { box-shadow: shadow-md; }
```

### Property Cards

```
10px radius, border 1px slate-200, overflow hidden, flex column

Header: space-4 space-5 padding
  Sale: bg blue-50, icon-bg blue-100, icon blue-500
  Rent: bg slate-50, icon-bg slate-100, icon slate-900
  Both: bg slate-50, icon-bg slate-200, icon slate-700
  Icon: 40x40, radius-md

Body: space-4 space-5 padding, rows flex gap space-2, text-md
Footer: space-3 space-5 padding, border-top 1px slate-100
  Price: text-lg weight 700 slate-900 | Agency: text-sm slate-400

Hover: translateY(-2px), shadow-lg
```

### Stat Cards

```
Grid: 4→2 (1024px)→1 (768px) col, gap space-5
radius-lg, border 1px slate-200, padding space-6

Left accent: 4px solid ::before (blue-500|slate-900|blue-400|slate-500)
Icon: 40x40, radius-md, variant bg
Number: text-xl weight 800 | Label: text-md weight 500 slate-500
Hover: shadow-md, translateY(-2px)
```

### Buttons

```css
display: inline-flex; align-items: center; gap: space-2;
padding: space-2 space-4; border-radius: radius-md;
font-size: text-md; font-weight: 500; transition: all 0.2s;
:hover { translateY(-1px); shadow-sm; }
:active { translateY(0); shadow none; }
```

| Variant | Bg | Text | Hover Bg |
|---------|-----|------|----------|
| primary | blue-500 | white | blue-600 |
| secondary | slate-100 | slate-700 | slate-200 |
| danger | slate-900 | white | blue-600 |
| sm | padding space-1 space-3, text-sm |

Auth buttons: full width, padding space-3 vertical.

### Form Inputs

```css
width: 100%; padding: space-3; border: 1px solid slate-200;
border-radius: radius-md; font-size: text-md; color: slate-900;
background: white; transition: border-color 0.2s, box-shadow 0.2s;
::placeholder { color: slate-400; }
:focus { border-color: blue-500; box-shadow: 0 0 0 3px blue-ring; outline: none; }
```

With icon: `padding-left: space-10`, icon at `left: space-3`, color slate-400.

### Badges

```css
padding: space-1 space-3; border-radius: radius-full;
font-size: text-sm; font-weight: 600;
letter-spacing: 0.5px; text-transform: uppercase;
/* Colors: see Badge table in DESIGN_SYSTEM.md */
```

### Tables

```css
width: 100%; border-collapse: collapse; background: white;
border-radius: radius-lg; overflow: hidden; border: 1px solid slate-200;

th { bg slate-50; text-sm weight 600 slate-500;
     uppercase; letter-spacing 0.5px; padding space-3 space-4; }
td { padding space-3 space-4; text-md; border-bottom 1px slate-100; }
tr:hover { bg slate-50; }
tr:last-child td { border-bottom: none; }
/* Mobile: wrap in overflow-x auto */
```

### Flash Messages

```css
padding: space-3 space-4; border-radius: radius-lg;
text-md weight 500; display flex; align-items center; gap space-3;
animation: flashIn 0.3s ease-out;

Success: bg blue-50, color blue-600, border 1px blue-100
Error: bg slate-50, color slate-900, border 1px slate-200
/* Differentiated by icon (checkmark/X), not color */
```

### Filters

```css
bg white; padding space-5; radius-lg; border 1px slate-200;
margin-bottom space-6; display flex; gap space-4; flex-wrap wrap; align-items end;
/* Mobile: flex-direction column, full-width */
```

### Pagination

```css
display flex; gap space-2; justify-content center; margin-top space-8;
Button: space-2 space-3 padding, 1px slate-200 border, radius-md, text-md weight 500 slate-700
Hover: bg slate-100
Active: bg blue-500, color white, border blue-500
```

### Quick-Link Cards

```
radius-lg, border 1px slate-200
Header: text-lg weight 700, padding space-5 space-6
Items: border-top 1px slate-100 (except first)
  Link: space-4 space-6, icon 40x40 radius-md palette bg
  Title: text-md weight 600 | Desc: text-sm slate-400
  Chevron: slate-400, hover blue-500 + translateX(2px)
```

### Auth Pages

```
Height: calc(100vh - 64px), auth gradient bg + grid overlay
Background gradient: linear-gradient(135deg, #eef2ff 0%, #f0f5ff 50%, #e8eeff 100%)
  (decorative blue tints derived from blue-50, not in core 16-token palette)
Card: max-width 440px, radius-lg, shadow-lg, padding space-8
Decorations: floating shapes slate-200 low opacity, hidden <480px
Brand above: icon 56x56 gradient radius-lg, name text-xl weight 800 blue-500,
  tagline text-md slate-500, space-8 below
```

### Hero (Homepage)

```
bg white, border-bottom 1px slate-200, text-align center
Padding: space-12 space-6 space-10
Title: text-xl weight 800 slate-900
Subtitle: text-md slate-500, max-width 520px centered, margin-bottom space-10
Search: radius-lg, 1px border, shadow-md, max-width 720px, padding space-5, gap space-3
Tabs: radius-full, active slate-900/white, inactive white/slate-500/1px slate-200
Mobile: stacked, padding space-8 space-4 space-8
```

### Empty States

```
text-align center; padding space-16 space-4; grid-column 1/-1
Icon: 48x48 slate-400 opacity 0.3 | Text: text-md slate-400
```

---

## Responsive

### Grid Patterns

```css
/* Properties: auto-fill minmax(320px,1fr) → repeat(2) ≥640 → repeat(3) ≥1024 */
/* Stats: repeat(4) → repeat(2) ≤1024 → 1fr ≤768 */
/* Dashboard quick-access: 1fr 1fr → 1fr ≤768 */
```

### Mobile Adaptations

| Component | Behavior |
|-----------|----------|
| Sidebar | Hidden, slide-out drawer with overlay |
| Hamburger toggle | Fixed top-left, 40x40, visible only on mobile |
| Forms | Rows stack to columns |
| Filters | Full-width, vertical |
| Tables | overflow-x auto wrapper |
| Auth decorations | Hidden <480px |
| Hero | Stacked search, reduced padding |
| Property grid | Single column |
| Container | space-5 space-4 padding, extra top padding for hamburger clearance |

---

## Icon Convention

- Inline SVG only (no icon library)
- Lucide/Feather style: `stroke-width="2" stroke-linecap="round" stroke-linejoin="round"`
- Sizes: 16px, 20px (default), 24px, 40px (containers), 48px (empty states)
- Color: `currentColor` or explicit palette token

---

## Update Triggers

Update this file when you:
- Add a new component pattern
- Change CSS architecture or global styles
- Add/remove a CDN dependency
- Change responsive breakpoint strategy
- Introduce a new layout pattern
