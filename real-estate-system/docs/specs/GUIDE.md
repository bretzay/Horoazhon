# Specification & Test Guide

This document defines how feature specifications and tests are written in this project.

---

## Architecture

Feature definitions and tests live in **separate files**:

```
docs/specs/
├── backend.json              # Backend feature definitions (Orchestrator-owned)
├── backend-tests.json        # Backend tests (QA-owned)
├── frontend-web.json         # Frontend feature definitions (Orchestrator-owned)
├── frontend-web-tests.json   # Frontend tests (QA-owned)
├── frontend-mobile.json      # Flutter mobile feature definitions (Orchestrator-owned)
├── frontend-mobile-tests.json # Flutter mobile tests (QA-owned)
└── GUIDE.md                  # This file
```

**Why separate?** Implementer agents read feature definitions to understand *what* to build. They never see the tests. QA writes tests independently based on the same definitions. This prevents agents from coding to pass specific assertions instead of properly implementing features.

---

## File Ownership

| File | Owner | Who can read | Who can write |
|------|-------|-------------|---------------|
| `backend.json` | Orchestrator (Role 8) | Everyone | Orchestrator; any role (except DevOps) can propose |
| `frontend-web.json` | Orchestrator (Role 8) | Everyone | Orchestrator; any role (except DevOps) can propose |
| `frontend-mobile.json` | Orchestrator (Role 8) | Everyone | Orchestrator; any role (except DevOps) can propose |
| `backend-tests.json` | QA (Role 4) | QA, Testing Agent | QA only |
| `frontend-web-tests.json` | QA (Role 4) | QA, Testing Agent | QA only |
| `frontend-mobile-tests.json` | QA (Role 4) | QA, Testing Agent | QA only |

**Implementers (Role 1, 2, 3) must never read test files.** They implement features based on the feature description alone.
**Security (Role 5) can propose specs in any spec file** — security requirements apply across all layers.

---

## Part 1: Writing Feature Specifications

### Who writes specs

- **Orchestrator** creates and approves specs (status: `not_tested`)
- **All other roles** (except DevOps) can propose specs (status: `proposed`):
  - **Implementers** (Role 1 Frontend, Role 2 Backend, Role 3 Flutter) — propose specs for features they're building
  - **QA** (Role 4) — propose coverage-gap specs for edge cases and missing test scenarios
  - **Security** (Role 5) — propose security-focused specs for attack vectors and auth requirements
  - **API Architect** (Role 7) — propose specs alongside new API contract definitions
- Proposals require Orchestrator approval before testing

### Feature definition schema

```json
{
  "id": "be-agence",
  "title": "Agency operations",
  "description": "Full description here...",
  "category": "agence",
  "status": "not_tested",
  "proposedBy": "orchestrator"
}
```

### Required fields

| Field | Description |
|-------|-------------|
| `id` | Unique identifier. Pattern: `be-{entity}[-suffix]` or `fe-{entity}[-suffix]` |
| `title` | Short, descriptive title |
| `description` | Full feature description (see below) |
| `category` | Grouping: auth, bien, agence, contrat, personne, user, reference, client, public, admin, layout |
| `status` | Lifecycle: `proposed` → `not_tested` → `passing` / `failing` |
| `proposedBy` | Who created it: `orchestrator`, `role-1`, `role-2`, etc. |

### Optional fields

| Field | Description |
|-------|-------------|
| `supersedes` | Array of spec IDs this feature replaces. Superseded specs are auto-removed when this spec is approved. |

### Naming conventions

- **No "crud" or "management" suffixes.** Use the entity name alone when one spec covers all operations.
- Use descriptive suffixes only when splitting an entity across multiple specs:
  - `-read` for list + search + detail (read-only operations)
  - `-write` for create/update/delete (mutation operations)
  - `-lifecycle` for workflow/status transitions
  - `-create` when creation is complex enough to warrant its own spec
- Examples: `be-personne` (all ops), `be-bien-read` + `be-bien-write` (split), `be-contrat-lifecycle` (workflow)

### Writing good descriptions

The description is the **single source of truth** for what a feature does. QA reads it to write tests. Implementers read it to build the feature. It must include:

#### 1. Endpoints or pages covered

```
Endpoints:
- GET /api/agences (public, paginated)
- GET /api/agences/{id} (public)
- POST /api/agences (SUPER_ADMIN only)
- PUT /api/agences/{id} (SUPER_ADMIN or own ADMIN_AGENCY)
- DELETE /api/agences/{id} (SUPER_ADMIN only)
```

#### 2. Role-based access rules (CRITICAL)

Every feature that has any access restriction **must** document:
- Which roles can perform each operation
- What happens when an unauthorized role attempts it (401 or 403)
- Any data isolation rules (e.g., "ADMIN_AGENCY sees only own agency's data")

```
Permissions:
- Public (no auth): GET list, GET detail
- SUPER_ADMIN: all operations
- ADMIN_AGENCY: PUT own agency only (403 on others), no create/delete
- AGENT: read only (403 on any write operation)
- CLIENT: read only (403 on any write operation)
- Unauthenticated on write endpoints: 401
```

**This section is not optional.** QA uses it to write permission test cases for every role × endpoint combination.

#### 3. Business rules and validation

```
Business rules:
- SIRET must be unique (409 on duplicate)
- Agency name is required (400 if missing)
- Deleting an agency with active contracts is forbidden (409)
- Agency logo upload accepts JPEG/PNG only, max 2MB
```

#### 4. Response shapes (for backend specs)

```
Response: AgenceDTO { id, nom, adresse, siret, telephone, email, logo, dateCreation }
List response: Page<AgenceDTO> { content[], totalElements, totalPages, size, number }
```

#### 5. Edge cases worth noting

```
Edge cases:
- Empty list returns page with totalElements=0, not 404
- Detail for nonexistent ID returns 404
- Update with no changes still returns 200
```

### Complete description example

```
Agency operations — full CRUD for real estate agencies.

Endpoints:
- GET /api/agences — public paginated list (page, size params)
- GET /api/agences/{id} — public detail
- GET /api/agences/{id}/biens — paginated list of agency's properties (authenticated)
- POST /api/agences — create agency (SUPER_ADMIN only)
- PUT /api/agences/{id} — update agency
- DELETE /api/agences/{id} — delete agency (SUPER_ADMIN only)

Permissions:
- Public: GET list, GET detail
- SUPER_ADMIN: all operations on any agency
- ADMIN_AGENCY: PUT own agency only (403 on other agencies), GET own agency biens, no create/delete (403)
- AGENT: GET own agency biens only (403 on write operations)
- CLIENT: public endpoints only (403 on authenticated endpoints)
- Unauthenticated: public endpoints only (401 on authenticated endpoints)

Business rules:
- nom is required (400 if missing)
- SIRET format validation
- Agency with active contracts cannot be deleted

Response: AgenceDTO { id, nom, adresse, siret, telephone, email, logo, dateCreation }
List: Page<AgenceDTO> with standard pagination fields

Edge cases:
- GET /api/agences/{id}/biens returns empty page (not 404) for agency with no properties
- Nonexistent agency ID returns 404
```

---

## Part 2: Writing Tests

### Who writes tests

- **QA (Role 4)** writes all tests based on feature descriptions
- **Testing Agent** runs tests and updates status
- **Implementers never read test files**

### Test file schema

```json
{
  "$schema": "spec-tests-v1",
  "role": "backend",
  "lastUpdated": "2026-03-03T00:00:00Z",
  "tests": [
    {
      "featureId": "be-agence",
      "writtenBy": "role-4",
      "suites": [
        {
          "id": "be-agence-crud-valid",
          "title": "Valid agency CRUD operations",
          "type": "http",
          "steps": [],
          "assertions": []
        }
      ]
    }
  ]
}
```

### Test types

| Type | Tool | Use for |
|------|------|---------|
| `http` | curl via Bash | Backend API endpoints |
| `browser` | Puppeteer MCP | Frontend web pages (DOM assertions, navigation, forms) |
| `flutter_integration` | `flutter test` via Bash | Flutter mobile app (runs on Android emulator via ADB) |

#### Flutter integration tests

Flutter integration tests run on an Android emulator connected from WSL2 via ADB. See `docs/FLUTTER_TESTING_SETUP.md` for full setup instructions.

Key differences from HTTP/browser tests:
- **Self-asserting**: assertions are written in Dart within the test files (`integration_test/*.dart`), not in the JSON spec
- **Steps in JSON**: describe what the test validates (for documentation), not executable commands
- **Execution**: `cd real-estate-system/frontend-mobile && flutter test integration_test/<file>.dart -d <device-id>`
- **Pass/fail**: determined by exit code (0 = pass, non-zero = fail)
- **Database reset**: required before test suites that hit the backend API

### Writing test steps (HTTP)

Each step is an HTTP request:

```json
{
  "description": "Login as SUPER_ADMIN",
  "method": "POST",
  "url": "http://localhost:8080/api/auth/login",
  "headers": { "Content-Type": "application/json" },
  "body": { "email": "superadmin@horoazhon.fr", "password": "Admin" },
  "extract": "token"
}
```

- `extract`: Save a response field for use in later steps. `"token"` saves `response.token` as `$token`. `"agenceId from id"` saves `response.id` as `$agenceId`.
- `auth_token`: Reference a previously extracted token: `"$token"`

### Writing test steps (Browser)

```json
{
  "description": "Navigate to login page",
  "action": "navigate",
  "url": "http://127.0.0.1:8001/login"
}
```

Actions: `navigate`, `fill` (selector + value), `click` (selector), `screenshot` (name), `wait_for_selector`, `select`.

### Writing assertions

```json
{ "type": "status_code", "value": 200 }
{ "type": "status_code", "value": 403 }
{ "type": "json_field_exists", "field": "token" }
{ "type": "json_field_equals", "field": "role", "value": "ADMIN_AGENCY" }
{ "type": "json_field_type", "field": "content", "value": "array" }
{ "type": "json_array_min_length", "field": "content", "value": 1 }
{ "type": "page_contains", "value": "Bienvenue" }
{ "type": "element_exists", "selector": ".navbar" }
{ "type": "url_contains", "value": "/admin" }
```

Always use `"value"` as the key (never `"expected"`).

### Permission testing checklist (MANDATORY)

**Every feature with access restrictions MUST have test cases for unauthorized access.** This is the most common source of security bugs.

For each endpoint/page, test with every role that should be DENIED:

```
Feature: be-agence (Agency operations)

Permission matrix to test:
┌──────────────────────┬───────────┬──────────┬───────┬────────┬──────────────┐
│ Operation            │ SUPER_ADM │ ADM_AGCY │ AGENT │ CLIENT │ Unauthed     │
├──────────────────────┼───────────┼──────────┼───────┼────────┼──────────────┤
│ GET /api/agences     │ 200       │ 200      │ 200   │ 200    │ 200 (public) │
│ POST /api/agences    │ 201       │ 403      │ 403   │ 403    │ 401          │
│ PUT /api/agences/:id │ 200       │ 200*     │ 403   │ 403    │ 401          │
│ DEL /api/agences/:id │ 204       │ 403      │ 403   │ 403    │ 401          │
└──────────────────────┴───────────┴──────────┴───────┴────────┴──────────────┘
* ADMIN_AGENCY: 200 for own agency, 403 for other agencies
```

**Every cell in this matrix should have a test case.** If an endpoint is public, test that it truly works without auth. If an endpoint requires a specific role, test that every other role gets 403.

### Test naming convention

Pattern: `{feature-id}-{what-is-tested}`

Examples:
- `be-agence-list-public` — unauthenticated list returns 200
- `be-agence-create-superadmin` — SUPER_ADMIN creates agency
- `be-agence-create-forbidden-admin` — ADMIN_AGENCY gets 403 on create
- `be-agence-update-own-agency` — ADMIN_AGENCY updates own agency
- `be-agence-update-other-forbidden` — ADMIN_AGENCY gets 403 on other agency
- `be-agence-delete-unauthenticated` — unauthenticated gets 401 on delete

### Test data and cleanup

**Tests must be idempotent.** They should produce the same result on every run.

Strategies:
1. **Use unique identifiers** with timestamps or random suffixes to avoid collisions
2. **Clean up after yourself** — if a test creates an entity, add a DELETE step at the end
3. **For entities that can't be deleted** (e.g., confirmed contracts), use test-specific data that doesn't interfere with other tests
4. **Never depend on specific IDs** from seed data — always create your own test entities in step 1

### Test accounts

| Email | Password | Role | Agency |
|-------|----------|------|--------|
| superadmin@horoazhon.fr | Admin | SUPER_ADMIN | none |
| admin@horoazhon.fr | Admin | ADMIN_AGENCY | Horoazhon France (id=1) |
| agent@horoazhon.fr | Agent | AGENT | Horoazhon France (id=1) |
| client@horoazhon.fr | Client | CLIENT | Horoazhon France (id=1) |
| admin@immosud.fr | Admin | ADMIN_AGENCY | Immobilier du Sud (id=2) |
| agent@immosud.fr | Agent | AGENT | Immobilier du Sud (id=2) |

---

## Part 3: Lifecycle

### Feature lifecycle

```
proposed → not_tested → passing / failing
                ↑            │
                └────────────┘  (code changes → re-test)
```

- **proposed**: Created by implementer/auditor, awaiting Orchestrator review
- **not_tested**: Approved by Orchestrator, ready for QA to write tests and Testing Agent to run them
- **passing**: All tests pass
- **failing**: At least one test fails

### Superseding specs

When a feature evolves and an implementer wants to replace an old spec:

1. Propose a new spec with `"supersedes": ["old-spec-id"]`
2. The old spec stays active until the Orchestrator approves the new one
3. On approval, superseded specs are automatically removed
4. If the new spec is rejected, nothing changes — the old spec remains

**Implementers never delete specs directly.** Only the Orchestrator can remove specs.

### Re-testing

To re-test a passing feature after code changes:
- The Orchestrator or Testing Agent resets status to `not_tested`
- The Testing Agent then re-runs the test suite
