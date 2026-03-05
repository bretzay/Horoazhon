# Public homepage
> Spec ID: fe-public-homepage | Category: public | Status: COMPLETE

## Implementation

### Files
- Template: `templates/home/index.html.twig`
- Controller: `Controller/HomeController.php` → route: `home` (GET)
- API methods: `getBiens(filters)` (page=0, size=6)

### What Exists
- Hero section with title "Trouvez votre bien ideal" and subtitle
- Search form with type tabs (Acheter/Louer), location, property type, price range
- Search redirects to `/biens` with query parameters
- Featured properties section showing 6 latest listings as property cards
- Property cards: type badge, title, price, surface, location
- Responsive layout: stacked search on mobile, reduced padding
- Navbar shows logged-in state for authenticated users

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Hero uses negative margins to break out of `.container` padding
- Property cards reuse the global `.property-card` component from `base.html.twig`
- Search tabs use radius-full pills with active/inactive states

### QA Remarks
- **Test coverage**: Page loads, hero section visible, search form functional, featured properties section, footer
- **UX concern (LOW)**: Search form has type tabs (Acheter/Louer) — verify selected tab carries over to /biens filter params correctly
- **Edge case**: No properties in database — verify featured section handles empty gracefully (no broken cards)
- **Responsiveness**: Verify stacked search on mobile, reduced padding

### Security Remarks
_None yet (Phase 2)_
