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
| page | integer | Page number (0-indexed, default 0) |
| size | integer | Page size (default 10) |

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

Delete a property. Requires authentication.

---

## User Roles

| Role | Code | Access |
|------|------|--------|
| Super Admin | SUPER_ADMIN | All agencies, reference data, user management |
| Agency Admin | ADMIN_AGENCY | Own agency data, staff management |
| Agent | AGENT | Own agency properties and contracts |
| Client | CLIENT | Personal dashboard, own properties/contracts |

---

## Database Migrations

| Version | Description |
|---------|-------------|
| V1 | Initial schema (all tables including Compte with token_reset/token_reset_expiration) |
| V2 | Test data (2 agencies, 18 persons, 5 accounts, 10 properties, 10 contracts, reference data, photos) |
