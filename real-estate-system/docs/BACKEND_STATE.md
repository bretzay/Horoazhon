# Backend State

> **Owner**: Role 2 — Backend + Database (Java Spring Boot)
> **Rule**: Read this file at session start. Update it after any structural change (new controller, endpoint, entity, service, DTO, repository, or migration).

---

## Controllers (11 files)

### AuthController — `/api/auth`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `login` | POST | `/api/auth/login` | Public |
| `activateAccount` | POST | `/api/auth/activate` | Public |
| `checkActivationToken` | GET | `/api/auth/activation-status` | Public |
| `inviteClient` | POST | `/api/auth/invite-client` | ADMIN_AGENCY, SUPER_ADMIN |
| `forgotPassword` | POST | `/api/auth/forgot-password` | Public |
| `checkResetToken` | GET | `/api/auth/reset-status` | Public |
| `resetPassword` | POST | `/api/auth/reset-password` | Public |
| `changePassword` | POST | `/api/auth/change-password` | Authenticated |
| `getCurrentUser` | GET | `/api/auth/me` | Authenticated |

### BienController — `/api/biens`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAllBiens` | GET | `/api/biens` | Public (filters archived; auth sees all) |
| `getBienById` | GET | `/api/biens/{id}` | Public |
| `getContratsByBien` | GET | `/api/biens/{bienId}/contrats` | Authenticated |
| `createBien` | POST | `/api/biens` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `updateBien` | PUT | `/api/biens/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `deleteBien` | DELETE | `/api/biens/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (409 if contracts exist) |
| `archiveBien` | PUT | `/api/biens/{id}/archive` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `unarchiveBien` | PUT | `/api/biens/{id}/unarchive` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `addCaracteristique` | POST | `/api/biens/{bienId}/caracteristiques` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `removeCaracteristique` | DELETE | `/api/biens/{bienId}/caracteristiques/{cId}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `addLieu` | POST | `/api/biens/{bienId}/lieux` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `removeLieu` | DELETE | `/api/biens/{bienId}/lieux/{lId}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `setProprietaire` | PUT | `/api/biens/{bienId}/proprietaire` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `removeProprietaire` | DELETE | `/api/biens/{bienId}/proprietaire` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `addPhoto` | POST | `/api/biens/{bienId}/photos` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |
| `removePhoto` | DELETE | `/api/biens/{bienId}/photos/{pId}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT (own agency) |

### AgenceController — `/api/agences`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAllAgences` | GET | `/api/agences` | Public |
| `getAgenceById` | GET | `/api/agences/{id}` | Public |
| `createAgence` | POST | `/api/agences` | SUPER_ADMIN |
| `updateAgence` | PUT | `/api/agences/{id}` | SUPER_ADMIN, ADMIN_AGENCY |
| `getAgenceBiens` | GET | `/api/agences/{id}/biens` | Public (supports ?actif= filter) |
| `deleteAgence` | DELETE | `/api/agences/{id}` | SUPER_ADMIN |

### ContratController — `/api/contrats`
Class-level: `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAll` | GET | `/api/contrats` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getById` | GET | `/api/contrats/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `create` | POST | `/api/contrats` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `updateStatut` | PATCH | `/api/contrats/{id}/statut` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `confirmContrat` | POST | `/api/contrats/{id}/confirm` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `cancelContrat` | POST | `/api/contrats/{id}/cancel` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `downloadPdf` | GET | `/api/contrats/{id}/pdf` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `uploadSignedDocument` | POST | `/api/contrats/{id}/document-signe` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `deleteSignedDocument` | DELETE | `/api/contrats/{id}/document-signe` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `downloadSignedDocument` | GET | `/api/contrats/{id}/document-signe` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `triggerExpirationCheck` | POST | `/api/contrats/expire-check` | SUPER_ADMIN only |

### PersonneController — `/api/personnes`
Class-level: `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAllPersonnes` | GET | `/api/personnes` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getPersonneById` | GET | `/api/personnes/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `searchPersonnes` | GET | `/api/personnes/search` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `createPersonne` | POST | `/api/personnes` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `updatePersonne` | PUT | `/api/personnes/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `deletePersonne` | DELETE | `/api/personnes/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getAccountStatus` | GET | `/api/personnes/{id}/account-status` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getPersonneBiens` | GET | `/api/personnes/{id}/biens` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getPersonneContrats` | GET | `/api/personnes/{id}/contrats` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |

### UserController — `/api/users`
Class-level: `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY')")`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `listUsers` | GET | `/api/users` | SUPER_ADMIN, ADMIN_AGENCY |
| `getUserById` | GET | `/api/users/{id}` | SUPER_ADMIN, ADMIN_AGENCY |
| `createUser` | POST | `/api/users` | SUPER_ADMIN, ADMIN_AGENCY |
| `deactivateUser` | DELETE | `/api/users/{id}` | SUPER_ADMIN, ADMIN_AGENCY |
| `reactivateUser` | PUT | `/api/users/{id}/reactivate` | SUPER_ADMIN, ADMIN_AGENCY |

### LocationController — `/api/locations`
Class-level: `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAll` | GET | `/api/locations` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getById` | GET | `/api/locations/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `create` | POST | `/api/locations` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `update` | PUT | `/api/locations/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `delete` | DELETE | `/api/locations/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |

### AchatController — `/api/achats`
Class-level: `@PreAuthorize("hasAnyAuthority('ROLE_SUPER_ADMIN','ROLE_ADMIN_AGENCY','ROLE_AGENT')")`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAll` | GET | `/api/achats` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `getById` | GET | `/api/achats/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `create` | POST | `/api/achats` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `update` | PUT | `/api/achats/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |
| `delete` | DELETE | `/api/achats/{id}` | SUPER_ADMIN, ADMIN_AGENCY, AGENT |

### CaracteristiquesController — `/api/caracteristiques`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAll` | GET | `/api/caracteristiques` | Public |
| `getById` | GET | `/api/caracteristiques/{id}` | Public |
| `create` | POST | `/api/caracteristiques` | SUPER_ADMIN |
| `update` | PUT | `/api/caracteristiques/{id}` | SUPER_ADMIN |
| `delete` | DELETE | `/api/caracteristiques/{id}` | SUPER_ADMIN |

### LieuxController — `/api/lieux`
| Method | Verb | Path | Auth |
|--------|------|------|------|
| `getAll` | GET | `/api/lieux` | Public |
| `getById` | GET | `/api/lieux/{id}` | Public |
| `create` | POST | `/api/lieux` | SUPER_ADMIN |
| `update` | PUT | `/api/lieux/{id}` | SUPER_ADMIN |
| `delete` | DELETE | `/api/lieux/{id}` | SUPER_ADMIN |

### ClientDashboardController — `/api/client`
Class-level: `@PreAuthorize("hasRole('CLIENT')")`
| Method | Verb | Path | Auth | Return Type |
|--------|------|------|------|-------------|
| `getDashboard` | GET | `/api/client/dashboard` | CLIENT only | ClientDashboardDTO |
| `getContracts` | GET | `/api/client/contrats` | CLIENT only | Page\<ContratDTO\> |
| `getProperties` | GET | `/api/client/biens` | CLIENT only | Page\<BienDTO\> |

**Total: ~83 endpoints across 11 controllers**

---

## Entities (14 files)

| Entity | Table | Key Columns |
|--------|-------|-------------|
| `Compte` | `Compte` | id, email (UNIQUE), password (BCrypt, NULL until activated), role (ENUM), agence_id (FK), personne_id (FK), token_activation, token_expiration, token_reset, token_reset_expiration, actif, date_creation |
| `Agence` | `Agence` | id, siret (UNIQUE), nom, numero_tva, rue, ville, code_postal, telephone, email, description, logo |
| `Bien` | `Bien` | id, rue, ville, code_postal, eco_score, superficie, description, type, actif (BIT DEFAULT 1), agence_id (FK), compte_createur_id (FK) |
| `Personne` | `Personne` | id, nom, prenom, date_nais, rue, ville, code_postal, rib, avoirs |
| `Contrat` | `Contrat` | id, statut (ENUM), type_contrat (LOCATION\|ACHAT), bien_id (FK NOT NULL), snap_mensualite, snap_caution, snap_duree_mois, snap_prix, snap_date_dispo, document_signe, compte_createur_id (FK) |
| `Location` | `Location` | id, caution, date_dispo, mensualite, duree_mois, bien_id (FK UNIQUE) |
| `Achat` | `Achat` | id, prix, date_dispo, bien_id (FK UNIQUE) |
| `Photo` | `Photo` | id, chemin, ordre, bien_id (FK) |
| `Caracteristiques` | `Caracteristiques` | id, lib |
| `Lieux` | `Lieux` | id, lib |
| `Contenir` | `Contenir` | bien_id + caracteristique_id (composite PK), unite, valeur |
| `Deplacer` | `Deplacer` | bien_id + lieu_id (composite PK), minutes, type_locomotion |
| `Posseder` | `Posseder` | bien_id + personne_id (composite PK), date_debut |
| `Cosigner` | `Cosigner` | contrat_id + personne_id (composite PK), type_signataire (ENUM), date_signature |

### Enums
| Enum | Values |
|------|--------|
| `Compte.Role` | CLIENT, AGENT, ADMIN_AGENCY, SUPER_ADMIN |
| `Contrat.StatutContrat` | EN_COURS, SIGNE, ANNULE, TERMINE |
| `Contrat.TypeContrat` | LOCATION, ACHAT |
| `Cosigner.TypeSignataire` | BUYER, SELLER, RENTER, OWNER |

---

## Services (13 files)

| Service | Responsibilities |
|---------|-----------------|
| `AuthService` | Login, account activation, password reset, password change, client invitation |
| `BienService` | Property CRUD, dynamic filtering, characteristics/lieux/photos/owner management, archive/unarchive |
| `AgenceService` | Agency CRUD |
| `ContratService` | Contract CRUD (via bienId+typeContrat), status management, confirm (deletes offer, cancels siblings), PDF document handling |
| `PersonneService` | Person CRUD, search, linked biens/contrats |
| `LocationService` | Rental listing CRUD |
| `AchatService` | Sale listing CRUD |
| `CaracteristiquesService` | Characteristic reference data CRUD |
| `LieuxService` | Place reference data CRUD |
| `ClientDashboardService` | Client dashboard aggregation, client's contracts/properties |
| `EmailService` | Async activation email sending |
| `ContratExpirationScheduler` | Daily cron (2:00 AM) to auto-terminate expired rental contracts |
| `ContratPdfService` | PDF generation for contracts (Apache PDFBox) |

---

## DTOs (31 files)

### Request DTOs
| DTO | Fields |
|-----|--------|
| `LoginRequest` | email, password |
| `RegisterRequest` | email, password, nom, prenom |
| `ActivateAccountRequest` | token, password |
| `ForgotPasswordRequest` | email |
| `ResetPasswordRequest` | token, password |
| `ChangePasswordRequest` | currentPassword, newPassword |
| `CreateBienRequest` | rue, ville, codePostal, type, superficie, description, ecoScore, agenceId |
| `UpdateBienRequest` | rue, ville, codePostal, type, superficie, description, ecoScore |
| `CreateLocationRequest` | bienId, caution, dateDispo, mensualite, dureeMois |
| `CreateAchatRequest` | bienId, prix, dateDispo |
| `CreateContratRequest` | bienId, typeContrat (LOCATION\|ACHAT), cosigners (list of CosignerRequest) |
| `CosignerRequest` | personneId, typeSignataire |
| `CreatePersonneRequest` | nom, prenom, dateNais, rue, ville, codePostal, rib |

### Response DTOs
| DTO | Key Fields |
|-----|-----------|
| `AuthenticationResponse` | token, type ("Bearer"), role, nom, prenom, agenceId, agenceNom, agenceLogo, personneId |
| `BienDTO` | id, rue, ville, codePostal, ecoScore, type, superficie, description, dateCreation, actif, agence, principalPhotoUrl, photoCount, photoUrls, availableForSale, availableForRent, salePrice, monthlyRent |
| `BienDetailDTO` | (extends BienDTO) + photos, caracteristiques, lieux, proprietaires, achat, location |
| `PhotoDTO` | id, chemin, ordre, url |
| `AgenceDTO` | id, siret, nom, numeroTva, rue, ville, codePostal, telephone, email, description, logo |
| `ContratDTO` | id, statut, type, hasSignedDocument, bien, cosigners, snapMensualite, snapCaution, snapDureeMois, snapPrix, snapDateDispo |
| `ContratDetailDTO` | (extends ContratDTO) + siblingContratCount |
| `LocationDTO` | id, caution, dateDispo, mensualite, dureeMois, bienId |
| `AchatDTO` | id, prix, dateDispo, bienId |
| `PersonneDTO` | id, nom, prenom, dateNais, rue, ville, codePostal, avoirs, rib |
| `CaracteristiqueDTO` | id, lib |
| `CaracteristiqueValueDTO` | caracteristiqueId, lib, unite, valeur |
| `LieuDTO` | id, lib |
| `LieuProximiteDTO` | lieuId, lib, minutes, typeLocomotion |
| `CosignerDTO` | personneId, nom, prenom, typeSignataire, dateSignature |
| `ProprietaireDTO` | personneId, nom, prenom, dateDebut |
| `ClientDashboardDTO` | personneId, nom, prenom, totalProperties, totalContracts, activeContracts, totalRevenue, monthlyRevenue, properties (List\<BienDTO\>), recentContracts (List\<ContratDTO\>), revenueByMonth (Map) |
| `PageResponse` | Generic pagination wrapper |
| `ErrorResponse` | error, message, status |

---

## Repositories (14 files)

| Repository | Entity | Notable Custom Methods |
|-----------|--------|----------------------|
| `CompteRepository` | Compte | `findByEmail`, `findByTokenActivation`, `findByTokenReset`, `findByAgenceId`, `findByAgenceIdAndRole` |
| `AgenceRepository` | Agence | `findBySiret`, `findByNomContainingIgnoreCase`, `findByVille` |
| `BienRepository` | Bien | `findByFilters(...)` (dynamic JPQL), `findByFiltersAndAgence(...)`, `findByAgenceId`, `findByAgenceIdAndActif`, `findByProprietaireId` |
| `ContratRepository` | Contrat | `findByIdWithDetails`, `findByBienId`, `findByBienIdAndTypeContrat`, `existsByBienId`, `existsSignedByBienIdAndType`, `existsEnCoursByBienIdAndType`, `findByPersonneId`, `findSignedRentalContracts`, `findByAgence` |
| `PersonneRepository` | Personne | `searchByNameIgnoreAccents` (native), `findProprietaires`, `findByAgence` (native UNION: Compte+Posseder+Cosigner paths), `searchByAgence` (native UNION + accent-insensitive filter) |
| `LocationRepository` | Location | Standard CRUD |
| `AchatRepository` | Achat | Standard CRUD |
| `PhotoRepository` | Photo | Standard CRUD |
| `CaracteristiquesRepository` | Caracteristiques | `findAllByOrderByLibAsc` |
| `LieuxRepository` | Lieux | `findAllByOrderByLibAsc` |
| `ContenirRepository` | Contenir | `existsById`, `deleteById` (composite key) |
| `DeplacerRepository` | Deplacer | `existsById`, `deleteById` (composite key) |
| `PossederRepository` | Posseder | `findByPersonneId`, `deleteByBienId` |
| `CosignerRepository` | Cosigner | `findByPersonneId` |

---

## Migrations

| Version | File | Description |
|---------|------|-------------|
| V1 | `V1__create_initial_schema.sql` | All 14 tables, constraints, indexes |
| V2 | `V2__create_test_data.sql` | 2 agencies, 18 persons, 6 accounts (incl. client@horoazhon.fr CLIENT), 14 properties (7 per agency), 10 contracts, reference data, photos |

**Next migration number: V3**

---

## Architecture Notes

- Dynamic JPQL query building in `BienService.findByFilters` for complex property search
- JWT auth via `JwtUtil` + Spring Security `AuthenticationManager`
- `@Transactional(readOnly = true)` on query services
- Entity-to-DTO conversion in service layer
- `@PreAuthorize` for role-based access control:
  - Class-level on ContratController, PersonneController, LocationController, AchatController (SUPER_ADMIN, ADMIN_AGENCY, AGENT)
  - Class-level on UserController (SUPER_ADMIN, ADMIN_AGENCY)
  - Class-level on ClientDashboardController (CLIENT only via hasRole)
  - Method-level on AgenceController, BienController write ops, CaracteristiquesController, LieuxController
- SecurityConfig public endpoints: GET /api/biens/*, GET /api/agences/*, GET /api/agences/*/biens, GET /api/caracteristiques/*, GET /api/lieux/*
- BienService agency scoping: write operations verify `bien.agence.id == currentAgenceId` for non-SUPER_ADMIN
- PersonneService agency isolation: list filtered by agency for non-SUPER_ADMIN users; search is global (allows cross-agency person lookup for contract creation)
- Apache PDFBox for contract PDF generation
- `@Scheduled` cron for auto-expiring rental contracts
- `@Async` email sending via `EmailService`
- Password reset/activation tokens: UUID-based, time-limited, single-use
- **Contract restructure**: Contrat references Bien directly (not via Location/Achat). Offer values are snapshotted at creation. Confirming a contract deletes the offer and cancels sibling EN_COURS contracts.
- **Property archiving**: Soft-delete via `actif` field. Public endpoints filter archived. Archive deletes offers and cancels EN_COURS contracts. DELETE returns 409 if contracts exist (suggests archive).
- **Offer creation guards**: LocationService/AchatService block create if SIGNE contract exists for same Bien+type. Delete blocked if EN_COURS contracts reference the offer.

---

## Update Triggers

Update this file when you:
- Add, rename, or delete a controller or endpoint
- Add, rename, or delete an entity or change its table mapping
- Add or remove a service or change its public API
- Add, rename, or delete a DTO or change its fields
- Add or remove a repository or custom query method
- Create a new migration (update the "Next migration number" line)
