# be-bien-read — Property listing and detail

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/BienController.java`
  - `getAllBiens` (line 26-51)
  - `getBienById` (line 53-57)
- **Service**: `backend/src/main/java/com/realestate/api/service/BienService.java`
  - `findAll` (line 40-216) — dynamic JPQL query engine
  - `findById` (line 218-223)
- **DTOs**: `BienDTO.java`, `BienDetailDTO.java`
- **Security**: Currently requires authentication (`.anyRequest().authenticated()` in SecurityConfig)

## Developer Notes
- **Status**: Fully implemented (code-wise), but SecurityConfig blocks public access
- **CRITICAL GAP**: GET /api/biens and GET /api/biens/{id} should be public but SecurityConfig requires auth for all non-/api/auth/** endpoints. Fix: add permitAll matchers for these GET endpoints.
- **Cascading issue**: `BienService.findAll()` line 110 calls `securityUtils.getCurrentAgenceId()` which calls `getCurrentCompteOrThrow()` — this throws for unauthenticated users. Must guard with `isAuthenticated()` check.
- Dynamic JPQL filtering works: search, type, price range, forSale/forRent, multi-characteristic, multi-lieu
- Minor: spec says `annonce` param, code uses `forSale`/`forRent` — keeping code's approach (boolean flags are clearer)

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
