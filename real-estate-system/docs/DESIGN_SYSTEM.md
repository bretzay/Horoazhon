# Horoazhon Design System — Shared Tokens

> Core design tokens shared across Web and Mobile. Platform-specific specs live in:
> - **Web**: [`DESIGN_WEB.md`](DESIGN_WEB.md) — Symfony/Twig components, CSS architecture, responsive rules
> - **Mobile**: [`DESIGN_FLUTTER.md`](DESIGN_FLUTTER.md) — ThemeData, Dart constants, widget mapping

---

## Design Principles

1. **2 colors, no exceptions.** Every color derives from Blue, Slate, White, or Black.
2. **4 font sizes only.** Hierarchy comes from weight and color, not extra sizes.
3. **8px grid.** All spacing is a multiple of 4px or 8px. No magic numbers.
4. **60-30-10 rule.** 60% white/neutral surfaces, 30% slate text/structure, 10% blue accents.
5. **Less is more.** When in doubt, remove. Whitespace is a feature.

---

## 1. Brand

- **Name**: Horoazhon
- **Tagline**: Gestion immobiliere simplifiee
- **Language**: French (hardcoded, no i18n)
- **Logo**: Slate-to-blue gradient square, white house icon
  - Gradient: `linear-gradient(135deg, blue-400, blue-500)`
  - Radius: `radius-lg` (large), `radius-md` (navbar)
  - Icon: white stroke, weight 2.5

---

## 2. Color Palette (16 tokens)

### Source colors

| Name | Hex | Role |
|------|-----|------|
| **Blue** | `#2563eb` | Primary — actions, links, interactive elements |
| **Slate** | `#0f172a` | Secondary — text, structure, dark UI |
| **White** | `#ffffff` | Light surfaces, text on dark |
| **Black** | `#000000` | Mixing base only (never used raw in UI) |

### All 16 tokens

| # | Token | Hex | Usage |
|---|-------|-----|-------|
| 1 | `blue-500` | `#2563eb` | Buttons, links, active states, focus borders |
| 2 | `blue-600` | `#1d4ed8` | Button hover, link hover |
| 3 | `blue-400` | `#3b82f6` | Gradient start, lighter accent |
| 4 | `blue-100` | `#dbeafe` | Icon backgrounds, highlight surfaces |
| 5 | `blue-50` | `#eff6ff` | Info background, sale headers |
| 6 | `slate-900` | `#0f172a` | Headings, strong labels, card titles |
| 7 | `slate-700` | `#334155` | Body text, form labels, nav items |
| 8 | `slate-500` | `#64748b` | Subtitles, descriptions, secondary text |
| 9 | `slate-400` | `#94a3b8` | Muted text, placeholders, disabled icons |
| 10 | `slate-200` | `#e2e8f0` | Borders, dividers, input outlines |
| 11 | `slate-100` | `#f1f5f9` | Table separators, secondary hover bg |
| 12 | `slate-50` | `#f8fafc` | Page background, subtle surface |
| 13 | `white` | `#ffffff` | Cards, navbar, footer, inputs, modals |
| 14 | `blue-ring` | `rgba(37,99,235,0.1)` | Focus ring on inputs |
| 15 | `shadow-color` | `rgba(15,23,42,0.06)` | Card shadows, elevation |
| 16 | `shadow-heavy` | `rgba(15,23,42,0.10)` | Dropdowns, prominent elevation |

### Semantic mapping (reuse tokens, no new colors)

| State | Text | Background | Border |
|-------|------|------------|--------|
| Default | `slate-700` | `white` | `slate-200` |
| Success | `blue-600` | `blue-50` | `blue-400` |
| Error | `slate-900` | `blue-100` | `blue-500` |
| Warning | `slate-700` | `slate-50` | `slate-200` |
| Info | `blue-500` | `blue-50` | `blue-100` |
| Disabled | `slate-400` | `slate-50` | `slate-200` |

> Success/error are differentiated by **icons** (checkmark vs X) and **copy**, not by color alone.

### Stat card variants

| Variant | Left border | Icon bg | Number color |
|---------|------------|---------|--------------|
| Primary | `blue-500` | `blue-100` | `blue-600` |
| Secondary | `slate-900` | `slate-100` | `slate-900` |
| Tertiary | `blue-400` | `blue-50` | `blue-500` |
| Quaternary | `slate-500` | `slate-50` | `slate-700` |

### Badge colors

| Badge | Background | Text |
|-------|-----------|------|
| Vente | `blue-500` | `white` |
| Location | `slate-900` | `white` |
| En cours | `blue-100` | `blue-600` |
| Signe | `slate-100` | `slate-900` |
| Annule | `slate-200` | `slate-700` |
| Termine | `blue-50` | `blue-500` |

### Role shield icons

| Role | Fill |
|------|------|
| `SUPER_ADMIN` | `slate-900` |
| `ADMIN_AGENCY` | `blue-500` |
| `AGENT` | `blue-400` |
| `CLIENT` | `slate-400` |

---

## 3. Typography (4 sizes)

**Font**: System font stack (no CDN dependency)
- Primary: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif`
- Renders as: SF Pro (macOS/iOS), Segoe UI (Windows), Roboto (Android/Chrome OS)
- Anti-AI-slop: avoids Inter which is the default AI-generated font choice

### Scale

| Token | Size | Px | Used for |
|-------|------|----|----------|
| `text-xl` | `1.5rem` | 24 | Hero titles, stat numbers, auth brand name |
| `text-lg` | `1.125rem` | 18 | Page H1, section H2, card headers |
| `text-md` | `0.875rem` | 14 | Body, labels, buttons, inputs, links, nav |
| `text-sm` | `0.75rem` | 12 | Badges, table headers, captions, timestamps |

### Weights

| Value | Use |
|-------|-----|
| `400` | Body paragraphs, descriptions |
| `500` | Labels, nav links, buttons |
| `600` | Card titles (at text-md), badge text, table headers |
| `700` | Page headings, prices, stat numbers |
| `800` | Hero title, brand name, stat display |

### Text color hierarchy

| Level | Token |
|-------|-------|
| Primary | `slate-900` — headings, titles, prices |
| Secondary | `slate-700` — body, labels |
| Tertiary | `slate-500` — subtitles, help text |
| Muted | `slate-400` — placeholders, disabled |
| Accent | `blue-500` — links, active items |

### Letter-spacing & Line-height

| Size | Spacing | Line-height |
|------|---------|-------------|
| `text-xl` | `-0.5px` | `1.2` |
| `text-lg` | `-0.25px` | `1.3` |
| `text-md` | `0` | `1.5` |
| `text-sm` | `0.25px` (`0.5px` uppercase) | `1.5` |

---

## 4. Spacing (8px grid)

| Token | Px | Rem | Common usage |
|-------|----|-----|--------------|
| `space-1` | 4 | `0.25rem` | Badge padding-y, tight gaps |
| `space-2` | 8 | `0.5rem` | Button gap, card-row gap, label↔input |
| `space-3` | 12 | `0.75rem` | Input padding, dropdown items, flash gap |
| `space-4` | 16 | `1rem` | Grid gap, card body, section spacing |
| `space-5` | 20 | `1.25rem` | Card padding extended, property grid gap |
| `space-6` | 24 | `1.5rem` | Card padding large, container sides, navbar |
| `space-8` | 32 | `2rem` | Section margins, page header bottom |
| `space-10` | 40 | `2.5rem` | Hero padding, large section gaps |
| `space-12` | 48 | `3rem` | Hero top (desktop) |
| `space-16` | 64 | `4rem` | Navbar height, empty state padding-y |

### Vertical rhythm

- Sibling sections: `space-8`
- Card → next element: `space-4`
- Heading → content: `space-4`
- Form fields: `space-4`
- Label → input: `space-2`

---

## 5. Border Radius (4 values)

| Token | Px | Usage |
|-------|-----|-------|
| `radius-sm` | 4 | Decorative shapes, micro-elements |
| `radius-md` | 8 | Buttons, inputs, pagination, dropdowns, brand icon (sm) |
| `radius-lg` | 16 | Cards, modals, tables, filters, auth card, brand icon (lg) |
| `radius-full` | 9999 | Badges, pills, user avatar button, search tabs |

> No `10px`, `12px`, `14px`. Pick the closest from this scale.

---

## 6. Shadows (3 levels)

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-sm` | `0 2px 8px rgba(15,23,42,0.06)` | Button hover |
| `shadow-md` | `0 4px 16px rgba(15,23,42,0.06)` | Card hover, stat hover, dropdown |
| `shadow-lg` | `0 8px 32px rgba(15,23,42,0.10)` | Auth card, modal, prominent elevation |

**Focus ring**: `box-shadow: 0 0 0 3px blue-ring;`

---

## 7. Icons

- **Method**: Inline SVG (no icon library)
- **Style**: Lucide/Feather — `stroke-width="2"`, `stroke-linecap="round"`, `stroke-linejoin="round"`
- **Sizes** (8px grid): 16px, 20px, 24px, 40px (containers), 48px (empty states)
- **Colors**: `currentColor` or explicit palette token
- **Containers**: square, `radius-md`, background from palette

---

## 8. Transitions

| Type | Duration |
|------|----------|
| Standard (color, bg, border, shadow) | `0.2s ease` |
| Fast (button, dropdown) | `0.15s ease` |
| Animation (flash entrance) | `0.3s ease-out` |

### Hover transforms

- Card lift: `translateY(-2px)`
- Button lift: `translateY(-1px)`
- Chevron slide: `translateX(2px)`
- Dropdown rotate: `rotate(180deg)`

---

## 9. Responsive Breakpoints

| Name | Max-width |
|------|-----------|
| Desktop | none |
| Tablet | `1024px` |
| Mobile | `768px` |
| Small mobile | `480px` |

---

## 10. Data Formatting

| Data | Format | Example |
|------|--------|---------|
| Currency (detail) | `number_format(v, 2, ',', ' ')` + ` EUR` | `250 000,00 EUR` |
| Currency (card) | `number_format(v, 0, ',', ' ')` + ` EUR` | `250 000 EUR` |
| Monthly rent | same + `/mois` | `1 200 EUR/mois` |
| Date | `d/m/Y` | `01/03/2026` |
| Property ID | `BI-{id}` | `BI-42` |
| Contract ID | `CTR-{id}` | `CTR-15` |
| Agency ID | `AG-{id}` | `AG-3` |
| Area | `{n} m²` | `85 m²` |

---

## 11. Accessibility

- Semantic HTML: `<nav>`, `<main>`, `<footer>`, `<header>`
- ARIA labels on icon-only buttons
- Focus ring on all interactive elements (`3px blue-ring`)
- Keyboard nav: dropdowns close on outside click + Escape
- Min touch target: 44px (mobile)
- Contrast: slate-900/white = 15.4:1, slate-700/white = 8.6:1, blue-500/white = 4.6:1 (WCAG AA)
- Success/error differentiated by icon + text, not color alone

---

## Quick Reference

```
COLORS:    blue-500 #2563eb | slate-900 #0f172a | + 14 derived tints/shades
FONTS:     text-xl 24px | text-lg 18px | text-md 14px | text-sm 12px
SPACING:   4  8  12  16  20  24  32  40  48  64
RADIUS:    4  8  16  9999
SHADOWS:   sm | md | lg
WEIGHTS:   400  500  600  700  800
```
