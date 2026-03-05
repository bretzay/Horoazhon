# Public property listing and detail
> Spec ID: fe-public-property | Category: public | Status: COMPLETE

## Implementation

### Files
- Templates: `templates/property/list.html.twig`, `templates/property/detail.html.twig`
- Controller: `Controller/BienPublicController.php` → routes: `biens_list` (GET), `biens_detail` (GET)
- API methods: `getBiens(filters)`, `getBienById(id)`, `getContratsByBien(id)`, `getCaracteristiques()`, `getLieux()`

### What Exists
- List page: paginated property grid (12 per page), filter bar (search, type, price range, announcement type)
- Per-characteristic filters: caracMin_*, lieuMax_*, lieuLoco_* query params
- Detail page: full property info, photo gallery, characteristics, proximity locations
- Agency info on detail page
- Contracts display restricted to non-CLIENT roles
- Empty state: "Aucun bien trouve" message
- Responsive: single column on mobile, 2-3 columns on desktop

### What's Missing
Nothing — feature is complete.

## Remarks

### Developer Notes
- Advanced filtering supports per-characteristic min/max values and proximity locations
- Detail page conditionally shows contracts section for admin/agent roles only
- Photo gallery displays all uploaded images with fallback placeholder

### QA Remarks
- **UX concern (LOW)**: No sort options visible in list page (price, date, surface mentioned in spec but unclear if implemented). Verify sort controls exist.
- **Test coverage**: List page loads with properties, filter by type/price/announcement, pagination works, detail page shows all sections, empty results message, nonexistent property ID
- **Edge case**: Applying multiple filters simultaneously — verify AND logic works correctly (e.g., type=APPARTEMENT AND prixMax=500 AND forRent=true)
- **Edge case**: Property with no photos should show placeholder image, not broken image
- **Responsiveness**: Verify grid changes from 3 columns (desktop) to 1 column (mobile)

### Security Remarks
_None yet (Phase 2)_
