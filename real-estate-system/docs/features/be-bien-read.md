# Property listing and detail
> Spec ID: be-bien-read | Category: bien | Status: not_tested

## Implementation

### Files
- Controller: `backend/src/main/java/com/realestate/api/controller/BienController.java` → GET /api/biens, GET /api/biens/{id}
- Service: `backend/src/main/java/com/realestate/api/service/BienService.java`
- DTOs: `BienDTO.java`, `BienDetailDTO.java`
- Repository: `BienRepository.java` (dynamic JPQL query building)

### What Exists
- GET /api/biens — public, paginated, with dynamic filters (search, type, price, caracMin, lieuMax, lieuLoco)
- GET /api/biens/{id} — public, returns BienDetailDTO with nested photos, caracteristiques, lieux, proprietaires, achat, location
- Dynamic JPQL filtering engine in BienService.findByFilters
- Dual listing support: both achat and location can be non-null

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: `GET /api/biens` and `GET /api/biens/{id}` are **public** — no `@PreAuthorize`. Any request (authenticated or not) can read properties.
- **Agency scoping on list**: If the caller is authenticated and has an `agenceId` (non-SUPER_ADMIN), the JPQL filter adds `AND b.agence.id = :agenceId` — they only see their own agency's properties. Unauthenticated users and SUPER_ADMIN (agenceId=null) see all properties.
- **Dynamic JPQL filter engine** (`BienService.findAll`): Builds JPQL string dynamically based on query params. Search splits into up to 5 words, each matched via `LIKE %word%` on concatenated ville+rue+codePostal+description. No SQL injection risk — uses parameterized queries (`params.put()`).
- **Multi-characteristic AND filters**: Params like `caracMin_1=3&caracMin_2=50` create separate `EXISTS` subqueries — all must match (AND logic). `CAST(valeur AS Integer)` may fail if valeur contains non-numeric data.
- **Multi-lieu filters**: `lieuMax_ID=minutes&lieuLoco_ID=locomotion`. Speed ranking logic: A_PIED < MARCHE < VELO < TRANSPORT_PUBLIC < VOITURE. If user asks for "VOITURE <= 5min", properties reachable A_PIED in 3min also qualify (slower modes included).
- **Detail endpoint**: `bienRepository.findByIdWithDetails(id)` uses `LEFT JOIN FETCH` for eager loading of photos, caracteristiques, lieux, proprietaires, achat, location. Returns `BienDetailDTO` with all nested data. Throws `EntityNotFoundException` → 404.
- **Error handling**: `EntityNotFoundException` → 404 via GlobalExceptionHandler. Invalid page numbers: Spring handles gracefully (empty page for out-of-range). Special characters in search: safe due to parameterized JPQL.
- **Property with no photos**: `principalPhotoUrl` will be null (no error). `photoCount` will be 0.

### QA Remarks
- **Test coverage**: 8 suites — public list, public detail, 404, type filter, empty results, dual listing, pagination, forSale filter
- **Complex filtering**: caracMin_{id} and lieuMax_{id} filters use dynamic JPQL — high risk of bugs with multiple simultaneous filters
- **Edge case**: Searching with special characters (quotes, SQL-like strings) — verify no injection
- **Edge case**: Invalid page number (negative, very large) — verify graceful handling
- **Edge case**: Property with no photos — verify principalPhotoUrl is null, not error

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
