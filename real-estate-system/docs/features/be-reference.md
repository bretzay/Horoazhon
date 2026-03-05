# Reference data operations
> Spec ID: be-reference | Category: reference | Status: not_tested

## Implementation

### Files
- Controllers: `CaracteristiquesController.java`, `LieuxController.java`
- Services: `CaracteristiquesService.java`, `LieuxService.java`
- DTOs: `CaracteristiqueDTO.java`, `LieuDTO.java`

### What Exists
- Full CRUD for Caracteristiques and Lieux
- GET (list, detail): Public — no auth required
- POST/PUT/DELETE: SUPER_ADMIN only (@PreAuthorize)
- Response: { id, lib } sorted alphabetically
- Alphabetical sorting via repository (findAllByOrderByLibAsc)

### What's Missing
Nothing — endpoints are complete.

## Remarks

### Developer Notes
- **Authorization**: GET (list, detail) are **public** — no `@PreAuthorize`. POST/PUT/DELETE use `@PreAuthorize("hasAuthority('ROLE_SUPER_ADMIN')")`. Only SUPER_ADMIN can create/update/delete reference data. All other roles get 403 from Spring Security.
- **Simple CRUD**: Both `Caracteristiques` and `Lieux` entities have `{id, lib}` structure. Sorted alphabetically via `findAllByOrderByLibAsc()` in the repository.
- **No uniqueness constraint on `lib`**: Two characteristics or lieux can have the same name. No duplicate check in the service layer. The DB schema also has no unique constraint on the `lib` column.
- **No cascade delete check**: Deleting a characteristic that is in use by properties (via the `Contenir` join table) will fail with `DataIntegrityViolationException` → 409 (generic constraint violation message). Same for lieux (via `Deplacer` join table). There is no descriptive error — just the generic "Une contrainte d'unicite a ete violee" message from GlobalExceptionHandler (which is misleadingly worded for FK violations).
- **Empty lib validation**: Depends on `@Valid` annotations on the DTO / `@NotBlank` on the `lib` field. If not present, empty strings are accepted.
- **Error handling**: `EntityNotFoundException` → 404, `DataIntegrityViolationException` → 409, `AccessDeniedException` → 403.

### QA Remarks
- **Test coverage**: 9 suites — public list/detail (both types), SUPER_ADMIN create (both), ADMIN_AGENCY forbidden, AGENT forbidden, unauthenticated
- **Good**: @PreAuthorize confirmed — proper Spring Security enforcement
- **Edge case**: Deleting a characteristic in use by existing properties — should fail or cascade
- **Edge case**: Duplicate lib value — no unique constraint documented, verify behavior
- **Edge case**: Empty lib value on create — should return 400

### Security Remarks
_To be filled by Role 5 (Security Auditor)_
