# Authentication System Setup Guide

## Backend Implementation Complete ✅

### What's Been Implemented:

1. **Database Schema**
   - Compte table with roles (CLIENT, AGENT, ADMIN_AGENCY, SUPER_ADMIN)
   - AgencePersonne linking table (many-to-many: agencies ↔ customers)
   - agent_createur_id tracking in Bien and Contrat tables

2. **Security Infrastructure**
   - JWT token generation and validation (JwtUtil)
   - Spring Security configuration (SecurityConfig)
   - Authentication filter (JwtAuthenticationFilter)
   - User details service (AgentUserDetailsService)

3. **API Endpoints**
   - POST /api/auth/login - Agent login
   - GET /api/auth/me - Get current agent info
   - GET /api/agents - List agents (admin only)
   - POST /api/agents - Create new agent (admin only)
   - DELETE /api/agents/{id} - Deactivate agent (admin only)

4. **Authorization Rules**
   - JWT required for all endpoints except /api/auth/** and public property listings
   - Role-based access control (@PreAuthorize annotations)
   - Agency isolation (agents can only manage their own agency's data)

---

## Setup Steps:

### 1. Run Database Migration

Execute the migration SQL (either via Flyway or manually):

```bash
# Location: backend/src/main/resources/db/migration/V3__add_authentication_system.sql
```

Or run manually in SQL Server Management Studio.

### 2. Create Test Agent

Run this SQL to create a test agent account:

```sql
-- First, get an existing agency ID
SELECT TOP 1 id, nom FROM Agence;

-- Create test agent (replace <AGENCE_ID> with actual ID from above)
-- Password is "password123" (BCrypt hashed)
INSERT INTO Agent (email, password, nom, prenom, agence_id, role, actif, date_creation)
VALUES (
    'admin@test.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Admin',
    'Test',
    <AGENCE_ID>,
    'ADMIN_AGENCY',
    1,
    GETDATE()
);
```

### 3. Test Authentication

**Login Request:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGc...",
  "type": "Bearer",
  "agent": {
    "id": 1,
    "email": "admin@test.com",
    "nom": "Admin",
    "prenom": "Test",
    "agenceId": 1,
    "agenceNom": "...",
    "role": "ADMIN_AGENCY",
    "actif": true
  }
}
```

**Get Current Agent:**
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Next Steps:

### Still To Implement:

1. **Agency Filtering** - Update repository queries to filter by agency
2. **Frontend Authentication**
   - Login page (Symfony)
   - Session management (store JWT)
   - Protected routes
3. **Navigation Updates**
   - Display agent info
   - Logout button
4. **Agent Management UI** - Page for agency admins to create/manage agents

### Configuration:

Add these to `application.properties` if needed:

```properties
# JWT Configuration
jwt.secret=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
jwt.expiration=86400000

# CORS (if frontend is on different port)
```

---

## Files Created:

**Entities:**
- Agent.java
- AgencePersonne.java
- Modified: Bien.java, Contrat.java

**Security:**
- JwtUtil.java
- AgentUserDetailsService.java
- JwtAuthenticationFilter.java
- SecurityConfig.java

**DTOs:**
- LoginRequest.java
- AuthenticationResponse.java
- AgentDTO.java
- CreateAgentRequest.java

**Services:**
- AuthService.java
- AgentService.java

**Controllers:**
- AuthController.java
- AgentController.java

**Repositories:**
- AgentRepository.java
- AgencePersonneRepository.java

**Migration:**
- V3__add_authentication_system.sql
