# API Documentation

## Base URL

`http://localhost:8080/api`

## Authentication

JWT-based authentication. All endpoints under `/api/auth/**` are public (no token required).
All other endpoints require a valid JWT token in the `Authorization: Bearer <token>` header.

---

## Auth Endpoints

### POST /api/auth/login

Authenticate a user and receive a JWT token.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "role": "ADMIN_AGENCY",
  "nom": "Dupont",
  "prenom": "Jean",
  "agenceId": 1,
  "agenceNom": "Immobilier Paris Centre",
  "agenceLogo": "https://...",
  "personneId": 1
}
```

### POST /api/auth/activate

Activate a new account by setting a password using the activation token.

**Request:**
```json
{
  "token": "uuid-activation-token",
  "password": "newpassword123"
}
```

**Response (200):**
```json
{
  "message": "Account activated successfully"
}
```

### GET /api/auth/activation-status?token=xxx

Check if an activation token is still valid.

**Response (200):**
```json
{
  "valid": true
}
```

### POST /api/auth/invite-client

Create a client account and generate an activation token. Requires authentication (ADMIN_AGENCY or SUPER_ADMIN).

**Request:**
```json
{
  "personneId": 5,
  "email": "client@example.com",
  "agenceId": 1
}
```
*Note: `agenceId` is required only for SUPER_ADMIN. Other roles auto-use their own agency.*

**Response (200):**
```json
{
  "message": "Invitation envoyee",
  "activationUrl": "http://localhost:8001/activate?token=uuid-token"
}
```

### POST /api/auth/forgot-password

Request a password reset email. Always returns success (doesn't reveal if email exists).

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "message": "Si un compte existe avec cet email, un lien de reinitialisation a ete envoye."
}
```

**Backend behavior:**
- Generates a UUID reset token stored in `Compte.token_reset`
- Sets expiration to 1 hour from now (`Compte.token_reset_expiration`)
- Logs the reset URL to console in dev mode (email sending not yet implemented)

### GET /api/auth/reset-status?token=xxx

Check if a password reset token is still valid.

**Response (200):**
```json
{
  "valid": true
}
```

### POST /api/auth/reset-password

Reset password using a valid reset token. Token is invalidated after use (single-use).

**Request:**
```json
{
  "token": "uuid-reset-token",
  "password": "newpassword123"
}
```

**Response (200):**
```json
{
  "message": "Mot de passe reinitialise avec succes."
}
```

**Error (400):**
```json
{
  "error": "Invalid or expired reset token"
}
```

### GET /api/auth/me

Get current authenticated user info. Requires valid JWT.

**Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "nom": "Dupont",
  "prenom": "Jean",
  "role": "ADMIN_AGENCY",
  "agenceId": 1,
  "agenceNom": "Immobilier Paris Centre",
  "agenceLogo": "https://...",
  "personneId": 1
}
```

---

## Bien Endpoints

### GET /api/biens

List properties with pagination and filters.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| search | string | Free text search (ville, rue, code postal, description) |
| type | string | APPARTEMENT, MAISON, STUDIO, TERRAIN |
| prixMin | number | Minimum price (sale or rent) |
| prixMax | number | Maximum price (sale or rent) |
| forSale | boolean | Filter properties available for sale |
| forRent | boolean | Filter properties available for rent |
| caracMin_{id} | integer | Minimum value for characteristic with given ID |
| lieuMax_{id} | integer | Maximum minutes to lieu with given ID |
| lieuLoco_{id} | string | Locomotion type for lieu filter (A_PIED, VELO, TRANSPORT_PUBLIC, VOITURE) |
| actif | boolean | Filter by active status (public requests always filter actif=true; authenticated can pass explicitly) |
| page | integer | Page number (0-indexed, default 0) |
| size | integer | Page size (default 10) |

**Visibility rules:** Public (unauthenticated) requests only see active properties (`actif=true`). Authenticated users see all properties by default, but can filter with `?actif=true` or `?actif=false`.

**Characteristic filters:** Multiple characteristics can be filtered simultaneously using `caracMin_1=3&caracMin_2=1`. All must match (AND logic).

**Proximity filters:** Multiple lieux can be filtered simultaneously. Each can optionally specify a locomotion type. Speed ranking applies: if you filter by VOITURE <= 5min, properties reachable by slower modes (A_PIED, VELO) in <= 5min also match.

**Speed ranking (slowest to fastest):** A_PIED/MARCHE < VELO < TRANSPORT_PUBLIC < VOITURE

**Response (200):** Paginated `Page<BienDTO>`

### GET /api/biens/{id}

Get detailed property information including photos, characteristics, proximity, and contracts.

**Response (200):** `BienDetailDTO`

### POST /api/biens

Create a new property. Requires authentication.

### PUT /api/biens/{id}

Update a property. Requires authentication.

### DELETE /api/biens/{id}

Delete a property. Returns **409 Conflict** if the property has any contracts (suggests archiving instead). Requires authentication.

**Response (409):**
```json
{
  "error": "Cannot delete property with existing contracts. Use archive instead."
}
```

### PUT /api/biens/{id}/archive

Archive a property (soft-delete). Guards: fails if a SIGNE contract exists. Side-effects: deletes Location/Achat offers, cancels all EN_COURS contracts on this property.

**Auth:** SUPER_ADMIN, ADMIN_AGENCY, AGENT

**Response (200):** `BienDTO` (with `actif: false`)

**Error (409):** If a SIGNE contract exists on this property.

### PUT /api/biens/{id}/unarchive

Restore an archived property.

**Auth:** SUPER_ADMIN, ADMIN_AGENCY, AGENT

**Response (200):** `BienDTO` (with `actif: true`)

---

## Agence Bien Listing

### GET /api/agences/{id}/biens

List properties for an agency with optional `actif` filter.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| actif | boolean | Filter by active status |
| page | integer | Page number (0-indexed, default 0) |
| size | integer | Page size (default 12) |

**Response (200):** `Page<BienDTO>`

---

## Personne Endpoints

### GET /api/personnes

List personnes. Agency-scoped for non-SUPER_ADMIN users (returns personnes linked to the user's agency via account, property ownership, or contract cosigning). SUPER_ADMIN sees all.

**Auth:** SUPER_ADMIN, ADMIN_AGENCY, AGENT (class-level `@PreAuthorize`)

**Response (200):** `List<PersonneDTO>`

### GET /api/personnes/{id}

Get personne detail by ID.

**Response (200):** `PersonneDTO { id, nom, prenom, dateNais, rue, ville, codePostal, avoirs, rib }`

### GET /api/personnes/search?q=...

Search personnes by name (accent-insensitive). **Global search** — returns matches from all agencies regardless of the caller's agency. This allows ADMIN_AGENCY/AGENT users to find existing personnes to add as cosigners on contracts.

**Auth:** SUPER_ADMIN, ADMIN_AGENCY, AGENT

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| q | string | Search term (matches nom or prenom, accent-insensitive) |

**Response (200):** `List<PersonneDTO>`

### POST /api/personnes

Create a new personne. The personne is not linked to any agency until associated via Compte, Posseder, or Cosigner.

**Request:**
```json
{
  "nom": "Dupont",
  "prenom": "Marie",
  "dateNais": "1990-01-15",
  "rue": "10 Rue de la Paix",
  "ville": "Paris",
  "codePostal": "75001",
  "rib": "FR7630001007941234567890185"
}
```

**Response (201):** `PersonneDTO`

### PUT /api/personnes/{id}

Update an existing personne. Partial updates supported (only non-null fields are updated).

**Response (200):** `PersonneDTO`

### DELETE /api/personnes/{id}

Delete a personne. Fails if personne has contracts or owns properties (referential integrity).

**Response (204):** No content

### GET /api/personnes/{id}/account-status

Check if a personne has a linked Compte.

**Response (200):**
```json
{
  "hasAccount": true,
  "status": "ACTIVE",
  "email": "user@example.com"
}
```

### GET /api/personnes/{id}/biens

Get properties owned by a personne (via Posseder table).

**Response (200):** `List<BienDTO>`

### GET /api/personnes/{id}/contrats

Get contracts where personne is a cosigner.

**Response (200):** `List<ContratDTO>`

---

## User Roles

| Role | Code | Access |
|------|------|--------|
| Super Admin | SUPER_ADMIN | All agencies, reference data, user management |
| Agency Admin | ADMIN_AGENCY | Own agency data, staff management |
| Agent | AGENT | Own agency properties and contracts |
| Client | CLIENT | Personal dashboard, own properties/contracts |

---

## Contract Model

Contracts now reference a **Bien** directly (not via Location/Achat offers). Offer values are snapshotted at contract creation.

### POST /api/contrats — Create Contract

**Request:**
```json
{
  "bienId": 1,
  "typeContrat": "LOCATION",
  "cosigners": [
    { "personneId": 5, "typeSignataire": "RENTER" },
    { "personneId": 3, "typeSignataire": "OWNER" }
  ]
}
```

- `typeContrat`: `"LOCATION"` or `"ACHAT"`
- The corresponding offer (Location or Achat) must exist on the Bien
- Offer values are copied to snapshot fields: `snapMensualite`, `snapCaution`, `snapDureeMois` (for LOCATION), `snapPrix`, `snapDateDispo` (for ACHAT)

### POST /api/contrats/{id}/confirm — Confirm Contract

Confirming a contract:
1. Deletes the corresponding offer from the Bien (Location or Achat)
2. Auto-cancels all other EN_COURS contracts of the same type on the same Bien

### ContratDTO Response Shape

```json
{
  "id": 1,
  "statut": "EN_COURS",
  "type": "LOCATION",
  "hasSignedDocument": false,
  "snapMensualite": 800.00,
  "snapCaution": 1600.00,
  "snapDureeMois": 12,
  "snapPrix": null,
  "snapDateDispo": "2025-01-15",
  "bien": { "id": 2, "rue": "...", "ville": "...", "actif": true },
  "cosigners": [...]
}
```

---

## Database Migrations

| Version | Description |
|---------|-------------|
| V1 | Initial schema (all tables including Compte with token_reset/token_reset_expiration) |
| V2 | Test data (2 agencies, 18 persons, 6 accounts incl. client@horoazhon.fr/Client/CLIENT, 14 properties (7 per agency), 10 contracts, reference data, photos) |
