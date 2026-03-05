# Frontend Web State

> **Owner**: Role 1 — Frontend Web (Symfony/Twig)
> **Rule**: Read this file at session start. Update it after any structural change (new controller, route, template, or API client method).

---

## Controllers (13 files)

| # | Controller | Route Prefix | Methods | Key Routes |
|---|-----------|-------------|---------|------------|
| 1 | `HomeController` | `/` | 1 | `home` |
| 2 | `AuthController` | — | 5 | `login`, `logout`, `activate_account`, `forgot_password`, `reset_password` |
| 3 | `AdminDashboardController` | `/admin` | 1 | `admin_dashboard` |
| 4 | `AdminBienController` | `/admin/biens` | 4 | `admin_biens`, `admin_biens_new`, `admin_biens_edit`, `admin_biens_delete` |
| 5 | `AdminAgenceController` | `/admin/agences` | 5 | `admin_agences`, `admin_agences_new`, `admin_agences_edit`, `admin_agence_settings`, `admin_agences_delete` |
| 6 | `AdminContratController` | `/admin/contrats` | 10 | `admin_contrats`, `admin_contrats_new`, `admin_contrats_detail`, `admin_contrats_pdf`, `admin_contrats_statut`, `admin_contrats_confirm`, `admin_contrats_cancel`, `admin_contrats_delete_signe`, `admin_contrats_upload_signe`, `admin_contrats_signed_pdf` |
| 7 | `AdminPersonneController` | `/admin/personnes` | 6 | `admin_personnes`, `admin_personnes_search_json`, `admin_personnes_new`, `admin_personnes_edit`, `admin_personnes_invite`, `admin_personnes_delete` |
| 8 | `AdminUserController` | `/admin/utilisateurs` | 4 | `admin_utilisateurs`, `admin_utilisateurs_new`, `admin_utilisateurs_deactivate`, `admin_utilisateurs_reactivate` |
| 9 | `AdminReferenceController` | `/admin/references` | 7 | `admin_references`, `admin_ref_carac_add`, `admin_ref_carac_edit`, `admin_ref_carac_delete`, `admin_ref_lieu_add`, `admin_ref_lieu_edit`, `admin_ref_lieu_delete` |
| 10 | `ClientDashboardController` | `/client` | 3 | `client_dashboard`, `client_contrats`, `client_biens` |
| 11 | `BienPublicController` | — | 2 | `biens_list`, `biens_detail` |
| 12 | `AgencePublicController` | — | 2 | `agences_list`, `agence_profile` |
| 13 | `ProfileController` | — | 2 | `profil`, `profil_change_password` |

**Total: 52 routes across 13 controllers**

---

## Templates (27 files)

```
templates/
├── base.html.twig                      # Base layout (navbar, footer, CSS, JS)
├── auth/
│   ├── login.html.twig                 # Login form + agency selector (hidden)
│   ├── activate.html.twig              # Account activation
│   ├── forgot-password.html.twig       # Forgot password form
│   └── reset-password.html.twig        # Reset password form
├── home/
│   └── index.html.twig                 # Public homepage
├── property/
│   ├── list.html.twig                  # Public property listing + filters
│   └── detail.html.twig                # Public property detail
├── agence/
│   ├── list.html.twig                 # Public agency listing
│   └── profile.html.twig              # Public agency profile
├── profil/
│   └── index.html.twig                # User profile management
├── admin/
│   ├── dashboard.html.twig            # Admin dashboard with stats
│   ├── bien/
│   │   ├── list.html.twig             # Property list
│   │   └── form.html.twig             # Property create/edit
│   ├── agence/
│   │   ├── list.html.twig             # Agency list
│   │   ├── form.html.twig             # Agency create/edit
│   │   └── settings.html.twig         # Agency settings (own agency)
│   ├── contrat/
│   │   ├── list.html.twig             # Contract list
│   │   ├── form.html.twig             # Contract create
│   │   └── detail.html.twig           # Contract detail
│   ├── personne/
│   │   ├── list.html.twig             # People list
│   │   └── form.html.twig             # Person create/edit
│   ├── user/
│   │   ├── list.html.twig             # User list
│   │   └── form.html.twig             # User create
│   └── reference/
│       └── index.html.twig            # Reference data (characteristics + places)
└── client/
    ├── dashboard.html.twig             # Client dashboard
    ├── biens.html.twig                 # Client properties
    └── contrats.html.twig              # Client contracts
```

---

## API Client Methods (RealEstateApiClient.php)

### Authentication
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `login(email, password)` | `POST /api/auth/login` | AuthController |
| `getCurrentUser()` | `GET /api/auth/me` | Multiple controllers |
| `checkActivationToken(token)` | `GET /api/auth/activation-status` | AuthController |
| `activateAccount(token, password)` | `POST /api/auth/activate` | AuthController |
| `requestPasswordReset(email)` | `POST /api/auth/forgot-password` | AuthController |
| `checkResetToken(token)` | `GET /api/auth/reset-status` | AuthController |
| `resetPassword(token, password)` | `POST /api/auth/reset-password` | AuthController |
| `changePassword(currentPassword, newPassword)` | `POST /api/auth/change-password` | ProfileController |
| `inviteClient(personneId, email)` | `POST /api/auth/invite-client` | AdminPersonneController |

### Properties (Biens)
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getBiens(filters)` | `GET /api/biens` | AdminBienController, BienPublicController |
| `getBienById(id)` | `GET /api/biens/{id}` | AdminBienController, BienPublicController |
| `getContratsByBien(bienId)` | `GET /api/biens/{bienId}/contrats` | AdminBienController |
| `createBien(data)` | `POST /api/biens` | AdminBienController |
| `updateBien(id, data)` | `PUT /api/biens/{id}` | AdminBienController |
| `deleteBien(id)` | `DELETE /api/biens/{id}` | AdminBienController |
| `addBienCaracteristique(...)` | `POST /api/biens/{id}/caracteristiques` | AdminBienController |
| `removeBienCaracteristique(...)` | `DELETE /api/biens/{id}/caracteristiques/{cId}` | AdminBienController |
| `addBienLieu(...)` | `POST /api/biens/{id}/lieux` | AdminBienController |
| `removeBienLieu(...)` | `DELETE /api/biens/{id}/lieux/{lId}` | AdminBienController |
| `setBienProprietaire(...)` | `PUT /api/biens/{id}/proprietaire` | AdminBienController |
| `removeBienProprietaire(...)` | `DELETE /api/biens/{id}/proprietaire` | AdminBienController |
| `addBienPhoto(...)` | `POST /api/biens/{id}/photos` | AdminBienController |
| `removeBienPhoto(...)` | `DELETE /api/biens/{id}/photos/{pId}` | AdminBienController |

### Agencies
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getAgences()` | `GET /api/agences` | AdminAgenceController |
| `getAgenceById(id)` | `GET /api/agences/{id}` | AdminAgenceController, AgencePublicController |
| `createAgence(data)` | `POST /api/agences` | AdminAgenceController |
| `updateAgence(id, data)` | `PUT /api/agences/{id}` | AdminAgenceController |
| `deleteAgence(id)` | `DELETE /api/agences/{id}` | AdminAgenceController |
| `getAgenceBiens(id, page, size)` | `GET /api/agences/{id}/biens` | AgencePublicController |

### People
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getPersonnes()` | `GET /api/personnes` | AdminPersonneController |
| `getPersonneById(id)` | `GET /api/personnes/{id}` | AdminPersonneController |
| `searchPersonnes(query)` | `GET /api/personnes/search` | AdminPersonneController |
| `createPersonne(data)` | `POST /api/personnes` | AdminPersonneController |
| `updatePersonne(id, data)` | `PUT /api/personnes/{id}` | AdminPersonneController |
| `deletePersonne(id)` | `DELETE /api/personnes/{id}` | AdminPersonneController |
| `getPersonneAccountStatus(id)` | `GET /api/personnes/{id}/account-status` | AdminPersonneController |
| `getPersonneBiens(id)` | `GET /api/personnes/{id}/biens` | AdminPersonneController |
| `getPersonneContrats(id)` | `GET /api/personnes/{id}/contrats` | AdminPersonneController |

### Contracts
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getContrats(filters)` | `GET /api/contrats` | AdminContratController |
| `getContratById(id)` | `GET /api/contrats/{id}` | AdminContratController |
| `createContrat(data)` | `POST /api/contrats` | AdminContratController |
| `updateContratStatut(id, statut)` | `PATCH /api/contrats/{id}/statut` | AdminContratController |
| `confirmContrat(id)` | `POST /api/contrats/{id}/confirm` | AdminContratController |
| `cancelContrat(id)` | `POST /api/contrats/{id}/cancel` | AdminContratController |
| `getContratPdf(id)` | `GET /api/contrats/{id}/pdf` | AdminContratController |
| `uploadContratSignedPdf(...)` | `POST /api/contrats/{id}/document-signe` | AdminContratController |
| `deleteContratSignedPdf(id)` | `DELETE /api/contrats/{id}/document-signe` | AdminContratController |
| `getContratSignedPdf(id)` | `GET /api/contrats/{id}/document-signe` | AdminContratController |

### Listings (Rentals + Sales)
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getLocations()` | `GET /api/locations` | AdminBienController |
| `createLocation(data)` | `POST /api/locations` | AdminBienController |
| `updateLocation(id, data)` | `PUT /api/locations/{id}` | AdminBienController |
| `deleteLocation(id)` | `DELETE /api/locations/{id}` | AdminBienController |
| `getAchats()` | `GET /api/achats` | AdminBienController |
| `createAchat(data)` | `POST /api/achats` | AdminBienController |
| `updateAchat(id, data)` | `PUT /api/achats/{id}` | AdminBienController |
| `deleteAchat(id)` | `DELETE /api/achats/{id}` | AdminBienController |

### Reference Data
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getCaracteristiques()` | `GET /api/caracteristiques` | AdminReferenceController, AdminBienController, BienPublicController |
| `createCaracteristique(data)` | `POST /api/caracteristiques` | AdminReferenceController |
| `updateCaracteristique(id, data)` | `PUT /api/caracteristiques/{id}` | AdminReferenceController |
| `deleteCaracteristique(id)` | `DELETE /api/caracteristiques/{id}` | AdminReferenceController |
| `getLieux()` | `GET /api/lieux` | AdminReferenceController, AdminBienController, BienPublicController |
| `createLieu(data)` | `POST /api/lieux` | AdminReferenceController |
| `updateLieu(id, data)` | `PUT /api/lieux/{id}` | AdminReferenceController |
| `deleteLieu(id)` | `DELETE /api/lieux/{id}` | AdminReferenceController |

### Client Dashboard
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getClientDashboard()` | `GET /api/client/dashboard` | ClientDashboardController |
| `getClientContrats(page, size)` | `GET /api/client/contrats` | ClientDashboardController |
| `getClientBiens(page, size)` | `GET /api/client/biens` | ClientDashboardController |

### User Management
| Method | API Endpoint | Used By |
|--------|-------------|---------|
| `getUsers(page, size)` | `GET /api/users` | AdminUserController |
| `createUser(data)` | `POST /api/users` | AdminUserController |
| `deactivateUser(id)` | `DELETE /api/users/{id}` | AdminUserController |
| `reactivateUser(id)` | `PUT /api/users/{id}/reactivate` | AdminUserController |

**Total: ~75 API client methods**

---

## CSS Architecture

- All CSS is inline in `base.html.twig` (~460 lines)
- No build pipeline, no CSS framework, no CDN fonts (system font stack)
- Design tokens from `docs/DESIGN_SYSTEM.md`
- Web-specific component specs in `docs/DESIGN_WEB.md`

## Layout Architecture

- **Sidebar layout**: Fixed 240px sidebar on left, main content area on right
- No top navbar — all navigation is in the sidebar
- Sidebar is role-adaptive: links change based on user role (SUPER_ADMIN, ADMIN_AGENCY, AGENT, CLIENT, unauthenticated)
- Mobile (<768px): sidebar hidden, toggled via hamburger button with slide-out drawer + overlay
- Active link highlighting based on current route
- User info and logout in sidebar footer

---

## Per-Feature Documentation

`docs/features/` contains 17 per-feature markdown files tracking implementation status, gaps, and cross-role remarks:

| File | Spec ID | Status |
|------|---------|--------|
| `fe-auth-login.md` | fe-auth-login | COMPLETE |
| `fe-auth-logout.md` | fe-auth-logout | COMPLETE |
| `fe-auth-activate.md` | fe-auth-activate | COMPLETE |
| `fe-auth-password-reset.md` | fe-auth-password-reset | COMPLETE |
| `fe-public-homepage.md` | fe-public-homepage | COMPLETE |
| `fe-public-property.md` | fe-public-property | COMPLETE |
| `fe-public-agence.md` | fe-public-agence | COMPLETE |
| `fe-layout.md` | fe-layout | COMPLETE |
| `fe-admin-dashboard.md` | fe-admin-dashboard | COMPLETE |
| `fe-admin-bien.md` | fe-admin-bien | COMPLETE |
| `fe-admin-agence.md` | fe-admin-agence | COMPLETE |
| `fe-admin-contrat.md` | fe-admin-contrat | COMPLETE |
| `fe-admin-personne.md` | fe-admin-personne | COMPLETE |
| `fe-admin-user.md` | fe-admin-user | COMPLETE |
| `fe-admin-reference.md` | fe-admin-reference | COMPLETE |
| `fe-client-dashboard.md` | fe-client-dashboard | COMPLETE |
| `fe-user-profile.md` | fe-user-profile | COMPLETE |

---

## Update Triggers

Update this file when you:
- Add, rename, or delete a controller
- Add, rename, or delete a route
- Add, rename, or delete a template
- Add or remove an API client method
- Change a route name or path
