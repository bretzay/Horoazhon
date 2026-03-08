# Horoazhon - Real Estate Management System

## Project Overview

Full-stack real estate management system for property buying, renting, and agency management.

- **Backend**: Java 17 + Spring Boot 3.2 REST API with SQL Server Express
- **Frontend Web**: PHP 8.2 + Symfony 7.0 (HTTP client to backend API)
- **Frontend Mobile**: Flutter/Dart
- **Database**: SQL Server Express (Flyway migrations)
- **Auth**: JWT-based, tokens stored in Symfony session

## Project Structure

```
real-estate-system/
├── backend/                    # Java Spring Boot REST API (port 8080)
│   └── src/main/java/com/realestate/api/
│       ├── config/             # SecurityConfig, CorsConfig
│       ├── controller/         # REST controllers (11 files)
│       ├── dto/                # Request/Response DTOs
│       ├── entity/             # JPA entities
│       ├── exception/          # Custom exceptions
│       ├── repository/         # Spring Data JPA repos
│       ├── security/           # JWT filter, SecurityUtils
│       ├── service/            # Business logic
│       └── util/               # Utilities
├── frontend-web/               # Symfony web app (port 8001, HTTPS)
│   ├── src/
│   │   ├── Controller/         # 13 Symfony controllers
│   │   ├── Service/            # RealEstateApiClient.php (API bridge)
│   │   └── Security/
│   └── templates/              # Twig templates
│       ├── admin/              # Admin dashboard, biens, agences, contrats, personnes, users, references
│       ├── auth/               # login, activate, forgot-password, reset-password
│       ├── client/             # Client dashboard
│       ├── home/               # Public homepage
│       ├── agence/             # Public agency pages
│       ├── property/           # Public property listings
│       ├── profil/             # User profile
│       └── base.html.twig      # Base layout (navbar, footer, Inter font, CDN libs)
├── frontend-mobile/            # Flutter app
│   └── lib/
│       ├── config/
│       ├── models/
│       ├── services/
│       ├── providers/
│       ├── screens/
│       └── widgets/
└── docs/                       # API_DOCUMENTATION, DATABASE_DEPLOYMENT, IMPLEMENTATION_GUIDE
```

---

## Project Phases

Development follows a phased approach. Each phase activates specific session roles.

### Phase 1: Website Completion (CURRENT)
**Active roles:** Frontend Web, Backend + Database
**Goal:** Complete all Symfony/Twig pages, implement remaining backend endpoints
**Exit criteria:** All admin/client pages functional, auth flow complete (including password reset), all CRUD operations working

### Phase 2: Website Audit
**Active roles:** QA/Testing, Security Auditor
**Goal:** Validate the full web application before building the mobile client
**Why before Flutter:** The mobile app consumes the same API — catching bugs now avoids fixing them in two clients later
**Exit criteria:**
- All API endpoints tested with valid and invalid inputs
- Role-based access verified (SUPER_ADMIN, ADMIN_AGENCY, AGENT, CLIENT)
- Frontend-backend contract alignment confirmed (no mismatched field names, missing endpoints)
- Auth flow fully tested (login, activation, password reset, session expiry)
- No critical security issues (injection, broken auth, data exposure)
- Responsive design validated across breakpoints

### Phase 3: Flutter Development
**Active roles:** Flutter Mobile, Backend + Database (for any missing mobile-specific endpoints)
**Goal:** Build the mobile app consuming the audited API
**Note:** API should be stable at this point — changes only for mobile-specific needs

### Phase 4: Final Audit & Deployment
**Active roles:** QA/Testing, Security Auditor, DevOps
**Goal:** Full system audit (web + mobile + API), then production deployment
**Exit criteria:** Both clients tested, security review passed, infrastructure ready

---

## Session Roles

### Role 1: Frontend Web (Symfony/Twig)
**Owns:** `frontend-web/templates/`, `frontend-web/public/`
**May edit:** `frontend-web/src/Controller/`, `frontend-web/src/Service/RealEstateApiClient.php`
**State doc (owns):** `docs/FRONTEND_WEB_STATE.md` — must read at session start, must update after structural changes
**Design doc (owns):** `docs/DESIGN_WEB.md` — must update when adding new component patterns or CSS changes
**Focus:** Template design, CSS styling, responsiveness, V0.app design adaptation, Twig logic, JavaScript interactions
**Never touches:** `backend/`, `frontend-mobile/`, database migrations
**Active in:** Phase 1

### Role 2: Backend + Database (Java Spring Boot)
**Owns:** `backend/src/`, `backend/src/main/resources/db/migration/`
**May edit:** `docs/API_DOCUMENTATION.md`
**State doc (owns):** `docs/BACKEND_STATE.md` — must read at session start, must update after structural changes
**Focus:** REST endpoints, business logic, JPA entities, services, security, email service
**Database responsibilities:**
- Schema design and Flyway migration scripts
- When creating or modifying migrations: always verify impact on existing data
- New migrations must be sequential (`V5__`, `V6__`, etc.) — check the latest migration number first
- After any migration change, verify that JPA entities still match the schema
**Verification rule:** Any migration that ALTERs an existing table must include a comment explaining the change and confirming no data loss
**Never touches:** `frontend-web/templates/`, `frontend-mobile/`
**Active in:** Phase 1, Phase 3 (if mobile needs new endpoints)

### Role 3: Flutter Mobile
**Owns:** `frontend-mobile/`
**May read:** `backend/src/main/java/com/realestate/api/dto/` (to match API contracts), `docs/API_DOCUMENTATION.md`
**Focus:** Dart/Flutter screens, widgets, state management (Provider), API service layer, responsive mobile UI
**Design rules:**
- Match the web design system (same color palette, same French text)
- Use Material Design components styled to match the web theme
- API service mirrors `RealEstateApiClient.php` patterns (same endpoints, same request/response shapes)
**Never touches:** `backend/`, `frontend-web/`
**Active in:** Phase 3

### Role 4: QA / Testing
**Owns:** Test plans, test results documentation
**May read:** Everything
**May edit:** `docs/` (test reports), backend test files (`backend/src/test/`)
**Focus:**
- API contract validation: verify frontend calls match backend responses exactly
- Role-based access testing: each role can only access what it should
- Edge cases: empty states, pagination boundaries, special characters, concurrent operations
- Integration testing: full flows (register → activate → login → CRUD → logout)
- Responsive testing: all breakpoints (1024px, 768px, 480px)
**Checklist for each endpoint:**
1. Valid request returns expected response shape
2. Invalid/missing params return proper error responses
3. Unauthorized access returns 401/403
4. Role-restricted endpoints enforce permissions
**Never touches:** Application source code (reports bugs, doesn't fix them)
**Active in:** Phase 2, Phase 4

### Role 5: Security Auditor
**Owns:** Security audit reports
**May read:** Everything
**May edit:** `docs/` (security reports)
**Focus:**
- **Authentication:** JWT implementation, token expiration, session handling, password hashing (BCrypt)
- **Authorization:** Role enforcement at API level (`@PreAuthorize`), session role checks in Symfony
- **Input validation:** SQL injection (Spring Data protects, but check raw queries), XSS in Twig templates (`|raw` filter usage), CSRF
- **Data exposure:** API responses don't leak sensitive fields (passwords, tokens, internal IDs they shouldn't see)
- **Configuration:** CORS settings, JWT secret strength, error messages that reveal internals, debug mode in production
- **Dependencies:** Known vulnerabilities in Maven/Composer packages
- **Specific attention areas for this project:**
  - Password reset tokens: ensure single-use, time-limited, and cryptographically random
  - Activation tokens: same validation
  - JWT claims: verify `agenceId` cannot be spoofed
  - File uploads (property photos): validate type, size, no path traversal
  - API client (`RealEstateApiClient.php`): no credential leakage in error messages
**Severity levels:** CRITICAL (fix before deploy), HIGH (fix soon), MEDIUM (should fix), LOW (nice to have)
**Never touches:** Application source code (reports findings with fix recommendations)
**Active in:** Phase 2, Phase 4

### Role 6: DevOps / Infrastructure
**Owns:** Docker configs, CI/CD pipelines, deployment scripts, server configuration
**May edit:** `docs/DATABASE_DEPLOYMENT.md`, root configs, `.env` templates, `application-prod.properties`
**Focus:** Containerization, server setup, database deployment, SSL certificates, reverse proxy (Nginx/Apache), monitoring
**Never touches:** Application business logic
**Active in:** Phase 4 (and on-demand for dev environment issues)

### Role 7: API Architect (On-Demand)
**Not a permanent session** — invoke when designing new features that span frontend and backend.
**Focus:**
- Define request/response contracts before implementation starts
- Decide endpoint structure, HTTP methods, status codes
- Document in `docs/API_DOCUMENTATION.md`
- Resolve ambiguities between frontend needs and backend capabilities
**When to use:** Before starting any new feature that requires new API endpoints (e.g., multi-agency login, new entity CRUD)

### Role 8: Orchestrator (Specification Authority)
**Owns:** `docs/specs/*.json` (backend.json, frontend-web.json)
**May read:** Everything (all source code, all docs)
**May edit:** `CLAUDE.md` (spec-related sections only)
**Never touches:** Application source code (`backend/src/`, `frontend-web/src/`, `frontend-web/templates/`, `frontend-mobile/`)
**Focus:** Feature specification authorship, proposal review, spec quality assurance
**Responsibilities:**
- Auto-generate specs for already-implemented features by reading code and docs
- Interactively define specs for new features with the user
- Review proposals from implementer agents (`status: "proposed"` → approve or reject)
- May NOT set `status` to `"passing"` or `"failing"` — only the Testing Agent can do that
**Active in:** All phases

---

## Coordination Rules

### File Conflict Prevention
- Each role has clear **Owns** / **May edit** / **Never touches** boundaries
- If two roles need to modify the same file, coordinate through the CLAUDE.md pending contracts section
- Frontend adds API client methods → Backend implements the endpoints → QA validates the match

### Migration Safety Protocol
1. Before creating a migration: check the latest `V*__` number in `backend/src/main/resources/db/migration/`
2. Name migrations descriptively: `V5__add_password_reset_tokens.sql` not `V5__update.sql`
3. Never modify an existing migration that has been applied — create a new one instead
4. ALTERing tables with existing data: include `-- Impact: <description>` comment
5. After creating a migration: update the corresponding JPA entity to match

### API Contract Handoff
When frontend needs a new backend endpoint:
1. Frontend documents the need in "Pending API Contracts" section below
2. Backend implements the endpoint matching the documented contract
3. Backend updates `docs/API_DOCUMENTATION.md`
4. Frontend updates `RealEstateApiClient.php` with the new method
5. QA validates the integration

---

## Documentation Governance

Each implementation role owns a **state doc** that tracks its structural inventory (controllers, entities, routes, templates, etc.). This keeps agents self-aware across sessions.

### Doc Ownership

| Doc | Owner | Purpose |
|-----|-------|---------|
| `docs/FRONTEND_WEB_STATE.md` | Role 1 (Frontend Web) | Controllers, routes, templates, API client methods |
| `docs/BACKEND_STATE.md` | Role 2 (Backend) | Controllers, endpoints, entities, services, DTOs, repos, migrations |
| `docs/API_DOCUMENTATION.md` | Role 2 (Backend) | Public API contract (read by all roles) |
| `docs/DESIGN_SYSTEM.md` | Shared (read-only) | Design tokens (colors, fonts, spacing) — do not edit without coordination |
| `docs/DESIGN_WEB.md` | Role 1 (Frontend Web) | Web-specific component patterns, CSS architecture |
| `docs/DESIGN_FLUTTER.md` | Role 3 (Flutter) | Flutter-specific ThemeData, widget mapping (to be created in Phase 3) |

### Session Start Protocol (Documentation)

Every implementation session **must** begin by reading its state doc:
1. **Read** your state doc to understand the current structural inventory
2. **Verify** the doc matches reality (spot-check a few files if uncertain)
3. If the doc is out of date, **update it first** before starting work

### Update Rules

After any structural change, update your state doc **before ending the task**. A structural change is:

| Role | Triggers a state doc update |
|------|----------------------------|
| Frontend Web | New/renamed/deleted controller, route, template, or API client method |
| Backend | New/renamed/deleted controller, endpoint, entity, service, DTO, repository, or migration |
| Flutter | New/renamed/deleted screen, widget, provider, model, or service (Phase 3) |

**Format**: Match the existing table/list format in the doc. Keep it factual (file names, route paths, method signatures) — no prose explanations.

**Cross-role doc updates**: If your change affects another role's doc (e.g., backend adds an endpoint that frontend will consume), do **not** edit the other role's doc. Instead, update `API_DOCUMENTATION.md` (shared contract) and note it in "Pending API Contracts" if the other role needs to act.

### Doc as Source of Truth

- When agents need to know "what exists," they check their state doc first — not by scanning the filesystem
- State docs are the canonical inventory; if a file exists but isn't in the doc, it should be added
- If a file is in the doc but doesn't exist, the doc entry should be removed

---

## Design System

Design documentation is split by platform. Each role reads **only** what it needs:

| Doc | Contains | Read by |
|-----|----------|---------|
| [`docs/DESIGN_SYSTEM.md`](real-estate-system/docs/DESIGN_SYSTEM.md) | Shared tokens: 16 colors, 4 font sizes, spacing grid, radius, shadows, icons, accessibility | All visual roles |
| [`docs/DESIGN_WEB.md`](real-estate-system/docs/DESIGN_WEB.md) | Web components, CSS architecture, responsive rules, layout patterns | Role 1 (Frontend Web) |
| [`docs/DESIGN_FLUTTER.md`](real-estate-system/docs/DESIGN_FLUTTER.md) | ThemeData, Dart constants, widget mapping (created in Phase 3) | Role 3 (Flutter) |

- **Frontend Web**: read `DESIGN_SYSTEM.md` + `DESIGN_WEB.md`
- **Flutter Mobile**: read `DESIGN_SYSTEM.md` + `DESIGN_FLUTTER.md`
- **QA / Security**: read `DESIGN_SYSTEM.md` only (for contrast/accessibility checks)

---

## User Roles (Application)

| Role | Code | Access |
|------|------|--------|
| Super Admin | `SUPER_ADMIN` | All agencies, reference data, user management |
| Agency Admin | `ADMIN_AGENCY` | Own agency data, staff management |
| Agent | `AGENT` | Own agency properties and contracts |
| Client | `CLIENT` | Personal dashboard, own properties/contracts |

---

## Key Routes

### Frontend Web (Symfony)
- `/` — Homepage (`home`)
- `/login` — Login (`login`)
- `/logout` — Logout (`logout`)
- `/activate?token=xxx` — Account activation (`activate_account`)
- `/forgot-password` — Forgot password (`forgot_password`)
- `/reset-password?token=xxx` — Reset password (`reset_password`)
- `/admin` — Admin dashboard (`admin_dashboard`)
- `/admin/biens` — Property list (`admin_biens`)
- `/admin/agences` — Agency management (`admin_agences`)
- `/admin/contrats` — Contract management (`admin_contrats`)
- `/admin/personnes` — People management (`admin_personnes`)
- `/admin/utilisateurs` — User management (`admin_utilisateurs`)
- `/admin/references` — Reference data (`admin_references`)
- `/client` — Client dashboard (`client_dashboard`)
- `/profil` — User profile (`profil`)

### Backend API
- `POST /api/auth/login` — JWT authentication
- `POST /api/auth/invite-client` — Invite client (creates account with activation token)
- `GET /api/auth/activation-status?token=xxx` — Check activation token
- `POST /api/auth/activate` — Activate account with password
- `GET /api/biens` — List properties (paginated, filterable)
- `GET /api/biens/{id}` — Property details
- CRUD endpoints for: agences, contrats, personnes, utilisateurs, locations, achats, caracteristiques, lieux

---

## Pending API Contracts (Backend TODO)

### Multi-Agency Login (Future)
Currently, each Compte has a single `agence_id` FK. When backend supports users belonging to multiple agencies, the login response should include:
```json
{
  "token": null,
  "agencies": [
    { "id": 1, "nom": "Paris Centre" },
    { "id": 2, "nom": "Lyon Sud" }
  ]
}
```
Then a second login request with `agenceId` completes authentication:
```
POST /api/auth/login  { "email": "...", "password": "...", "agenceId": 1 }
```
The frontend agency selector UI is pre-built in login.html.twig (hidden until this is implemented).

---

## Specification-Driven Testing

Feature specifications and tests live in **separate files** under `docs/specs/`. This separation prevents implementer agents from coding to pass specific assertions instead of properly implementing features. See [`docs/specs/GUIDE.md`](real-estate-system/docs/specs/GUIDE.md) for the full specification and test writing guide.

### File Structure

```
docs/specs/
├── backend.json              # Backend feature definitions (Orchestrator-owned)
├── backend-tests.json        # Backend tests (QA-owned)
├── frontend-web.json         # Frontend feature definitions (Orchestrator-owned)
├── frontend-web-tests.json   # Frontend tests (QA-owned)
└── GUIDE.md                  # Spec & test writing guide
```

### Agent Permissions

| Agent | Can do | Cannot do |
|-------|--------|-----------|
| **Orchestrator** (Role 8) | Create specs, approve/reject proposals, set `"not_tested"` | Set `"passing"`/`"failing"`, modify source code, write tests |
| **Implementers** (Role 1, 2, 3) | Propose specs (`"proposed"`), run `/test-spec` | Approve specs, read test files, modify status/result fields |
| **QA** (Role 4) | Read all specs, write tests, propose coverage-gap specs, run `/test-spec` | Approve specs, modify source code |
| **Security** (Role 5) | Read all specs, propose security specs, run `/test-spec` | Approve specs, modify source code |
| **API Architect** (Role 7) | Propose specs alongside API contracts | Approve specs, modify source code |
| **DevOps** (Role 6) | Read `/specs` for deployment readiness | Propose specs, modify specs |
| **Testing Agent** (subagent) | Run tests, set `"passing"`/`"failing"`, update `lastResult` | Modify feature definitions, modify source code |

**Status lifecycle:** `"proposed"` → `"not_tested"` → `"passing"` / `"failing"`

**Supersede pattern:** Agents propose replacement specs with `"supersedes": ["old-id"]`. Old specs are auto-removed when the new spec is approved by the Orchestrator.

**Skills:**
- `/specs` — View status dashboard of all feature specifications (includes all spec files)
- `/test-spec <feature-id>` — Run tests for a feature via the independent Testing Agent
- `/propose-spec` — Propose a new feature specification (implementer, QA, Security, and Architect agents)

**Test types:** HTTP (curl to API endpoints) and Browser (Puppeteer MCP for UI interaction)

---

## Database

- **Engine**: SQL Server Express (local dev), SQL Server (production)
- **Migrations**: Flyway (`backend/src/main/resources/db/migration/`)
- **Key tables**: Bien, Contrat, Agence, Personne, Compte, Location, Achat, Photo, Caracteristiques, Lieux, etc.
- **Auth fields on Compte**: `email` (UNIQUE), `mot_de_passe` (BCrypt), `role`, `agence_id` (FK), `token_activation`, `token_expiration`
- **Flyway status**: Operational. Current migrations: V1 (schema + auth with password reset columns) + V2 (test data). Use `/check-migrations` to find the next available migration number.

---

## Development Setup

```bash
# Backend (requires Java 17+, Maven, SQL Server Express)
cd real-estate-system/backend
mvn clean spring-boot:run              # Runs on http://localhost:8080

# Frontend Web (requires PHP 8.2+, Composer, Symfony CLI)
cd real-estate-system/frontend-web
symfony server:start --port=8001       # Runs on https://localhost:8001

# Frontend Mobile (requires Flutter SDK)
cd real-estate-system/frontend-mobile
flutter run
```

---

## Conventions

- All UI text is in **French** (no i18n framework, hardcoded strings)
- Monospace IDs in tables: `BI-{id}` for biens, `CTR-{id}` for contracts, `AG-{id}` for agencies
- Currency format: `number_format(value, 2, ',', ' ')` with ` EUR` suffix
- Date format: `d/m/Y` for display
- API client is the single bridge: all backend calls go through `RealEstateApiClient.php`
- Template inheritance: all pages extend `base.html.twig`
- Admin pages use `admin/base_admin.html.twig` layout with sidebar navigation
- Auth pages (login, activate, forgot/reset password) use full-page centered card with decorative background

---

## Session Launch Protocol

When starting a new Claude session, assign its role with one of these opening messages. Each role **must read its state doc** immediately after reading CLAUDE.md.

**Frontend Web session:**
> You are Role 1: Frontend Web. Read CLAUDE.md, then read `docs/FRONTEND_WEB_STATE.md` and `docs/DESIGN_WEB.md`. Run `/specs` to see the current spec dashboard. Then index the PHP source for jcodemunch (`mcp__jcodemunch-mcp__index_folder path: real-estate-system/frontend-web/src incremental: true`) — this enables symbol and text search across Symfony controllers and services for the rest of the session. Do NOT index templates (Twig files are not supported by jcodemunch). We are in Phase 1. Focus on completing Symfony/Twig templates. Proactively identify features that need specs and guide the user in proposing them via `/propose-spec`. After implementing a feature, validate it with `/test-spec`. Update your state doc after any structural change.

**Backend + Database session:**
> You are Role 2: Backend + Database. Read CLAUDE.md, then read `docs/BACKEND_STATE.md` and `docs/API_DOCUMENTATION.md`. Run `/specs` to see the current spec dashboard. Then index the Java source for jcodemunch (`mcp__jcodemunch-mcp__index_folder path: real-estate-system/backend/src/main/java/com/realestate/api incremental: true`) — this enables symbol and text search across all controllers, services, DTOs, and entities for the rest of the session. We are in Phase 1. Focus on implementing pending API contracts and completing endpoints. Proactively identify features that need specs and guide the user in proposing them via `/propose-spec`. After implementing a feature, validate it with `/test-spec`. Update your state doc after any structural change.

**Flutter Mobile session (Phase 3):**
> You are Role 3: Flutter Mobile. Read CLAUDE.md, then read `docs/API_DOCUMENTATION.md` and `docs/DESIGN_SYSTEM.md`. Run `/specs` to see the current spec dashboard. Then index the Dart source for jcodemunch (`mcp__jcodemunch-mcp__index_folder path: real-estate-system/frontend-mobile/lib incremental: true`) — this enables symbol and text search across all screens, widgets, services, and providers for the rest of the session. We are in Phase 3. Build the mobile app consuming the audited API. Match the web design system. Proactively identify features that need specs and guide the user in proposing them via `/propose-spec`. After implementing a feature, validate it with `/test-spec`. Create and maintain `docs/FLUTTER_STATE.md`.

**QA / Testing session (Phase 3):**
> You are Role 4: QA/Testing. Read CLAUDE.md, then read `docs/BACKEND_STATE.md`, `docs/FRONTEND_WEB_STATE.md`, `docs/FLUTTER_STATE.md`, `docs/API_DOCUMENTATION.md`, and `docs/FLUTTER_TESTING_SETUP.md`. Run `/specs` to see the current spec dashboard. Then index all three codebases for jcodemunch: `mcp__jcodemunch-mcp__index_folder path: real-estate-system/backend/src/main/java/com/realestate/api incremental: true` and `mcp__jcodemunch-mcp__index_folder path: real-estate-system/frontend-web/src incremental: true` and `mcp__jcodemunch-mcp__index_folder path: real-estate-system/frontend-mobile/lib incremental: true`. Do NOT index templates. We are in Phase 3. Use `/test-spec` to validate features systematically — prioritize `not_tested` then `failing` specs across backend, frontend-web, and frontend-mobile specs. For Flutter integration tests (`type: flutter_integration`), generate the PowerShell commands and ask the user to run them in Windows PowerShell and paste the output back — Flutter cannot run from WSL2. Use `/propose-spec` to propose coverage-gap specs for edge cases, error paths, and boundary conditions. Do not modify application code.

**Security Auditor session (Phase 2/4):**
> You are Role 5: Security Auditor. Read CLAUDE.md, then read `docs/BACKEND_STATE.md` and `docs/API_DOCUMENTATION.md`. Run `/specs` to see the current spec dashboard. Then index both codebases for jcodemunch: `mcp__jcodemunch-mcp__index_folder path: real-estate-system/backend/src/main/java/com/realestate/api incremental: true` and `mcp__jcodemunch-mcp__index_folder path: real-estate-system/frontend-web/src incremental: true`. Do NOT index templates. We are in Phase 2. Audit authentication, authorization, input validation, and data exposure. Use `/propose-spec` to propose security-focused specs for attack vectors and security requirements. Use `/test-spec` to validate security-relevant features. Report findings only — do not modify code.

**DevOps / Infrastructure session (Phase 4):**
> You are Role 6: DevOps. Read CLAUDE.md. Run `/specs` to assess deployment readiness — check how many features are passing vs failing. We are in Phase 4. Focus on containerization, server setup, database deployment, and CI/CD. Do not modify application business logic.

**API Architect session (On-Demand):**
> You are Role 7: API Architect. Read CLAUDE.md, then read `docs/API_DOCUMENTATION.md` and `docs/BACKEND_STATE.md`. Run `/specs` to see the current spec dashboard. Design request/response contracts before implementation starts. Use `/propose-spec` to create specs alongside new API contract definitions. Document in `docs/API_DOCUMENTATION.md`.

**Orchestrator session (All phases):**
> You are Role 8: Orchestrator. Read CLAUDE.md, then read `docs/BACKEND_STATE.md`, `docs/FRONTEND_WEB_STATE.md`, and `docs/API_DOCUMENTATION.md`. Run `/specs` to see the current dashboard and identify any `proposed` specs awaiting review. Use `/read-specs` to examine individual specs — do not read spec JSON files directly. Generate specs for existing features and help define specs for new features interactively. Review proposals from implementer, QA, Security, and Architect agents — check `proposedBy` to understand each proposal's origin.

---

## Available Skills (Slash Commands)

These project-level skills are available in all sessions:

| Command | Description |
|---------|-------------|
| `/review-role` | Display the current session's role boundaries and file ownership |
| `/check-contracts` | Show pending API contracts that need backend implementation |
| `/check-migrations` | Check migration numbering before creating a new migration |
| `/sync-status` | Show cross-session changes grouped by role |
| `/start-backend` | Start Spring Boot server, wait for health check, report Flyway status |
| `/start-frontend` | Start Symfony frontend server, wait for health check, report status |
| `/reset-db` | Full database reset: drop all tables, Flyway rebuild, verify integrity |
| `/check-backend` | Quick diagnostic: is the backend running? What's the DB state? |
| `/specs` | View status dashboard of all feature specifications |
| `/test-spec` | Run tests for a feature via the independent Testing Agent |
| `/propose-spec` | Propose a new feature specification (implementer, QA, Security, Architect agents) |
| `/read-specs` | Query specs with filters — dashboard, list by file/category/status, or single-spec detail |
| `/write-spec` | Write, replace, or remove a single spec (role-enforced: implementors revert confirmed specs to proposed) |
| `/write-test` | Write test suites for a feature in a test file (QA only) |
| `/bulk-specs` | Batch operations: replace category, bulk-approve status, remove multiple IDs |
| `/analyze` | Generate or refresh a feature analysis document (codebase search + cross-role context) |
| `/annotate` | Add a note to a feature's analysis document (role-enforced sections) |

---

## Model Selection Per Role

| Role | Default Model | Use Opus When |
|------|--------------|---------------|
| Frontend Web | Sonnet | Complex responsive layouts, V0 design adaptation |
| Backend API | Sonnet | Security-sensitive code, complex business logic |
| Flutter Mobile | Sonnet | State management architecture |
| QA / Testing | Sonnet | — |
| Security Auditor | Opus | Always (needs deep analysis) |
| Orchestrator | Sonnet | Complex multi-feature spec generation |
