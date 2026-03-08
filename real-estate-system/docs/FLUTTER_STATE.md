# Flutter Mobile State

> **Owner**: Role 3 — Flutter Mobile
> **Rule**: Read this file at session start. Update it after any structural change (new screen, widget, provider, model, or service).

---

## Current Structure (Phase 3 — In Progress)

```
frontend-mobile/
├── lib/
│   ├── main.dart                    # App entry point with Provider + AppTheme
│   ├── config/
│   │   ├── api_config.dart          # API base URL and timeout config
│   │   ├── app_colors.dart          # AppColors, StatCardColors (16 palette tokens + semantic)
│   │   ├── app_text_styles.dart     # AppTextStyles, TextStyleX, AppTextComposed
│   │   ├── app_spacing.dart         # AppSpacing (4px grid)
│   │   ├── app_radius.dart          # AppRadius (sm/md/lg/full)
│   │   ├── app_shadows.dart         # AppShadows (sm/md/lg/focusRing)
│   │   ├── app_theme.dart           # AppTheme.build() — full ThemeData
│   │   ├── app_formatters.dart      # AppFormatters (currency, date, IDs, area)
│   │   └── app_icons.dart           # AppIconSizes (xs/sm/md/lg/xl)
│   ├── models/                      # (empty — models to be created)
│   ├── providers/
│   │   └── auth_provider.dart       # AuthProvider — login, logout, role state, secure storage
│   ├── screens/
│   │   ├── home_screen.dart         # Accueil (placeholder)
│   │   ├── property_list_screen.dart # Biens list (placeholder)
│   │   ├── agency_list_screen.dart  # Agences list (placeholder)
│   │   ├── profile_screen.dart      # Profil (placeholder)
│   │   ├── login_screen.dart        # Connexion (placeholder)
│   │   ├── client_dashboard_screen.dart # Client dashboard (placeholder)
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart # Admin tableau de bord (placeholder)
│   │       ├── admin_biens_screen.dart    # Admin gestion biens (placeholder)
│   │       └── admin_contrats_screen.dart # Admin gestion contrats (placeholder)
│   ├── services/
│   │   └── api_service.dart         # Dio HTTP client with JWT interceptor
│   └── widgets/
│       ├── app_shell.dart           # Main scaffold with role-adaptive bottom nav + drawer
│       ├── admin_drawer.dart        # Drawer navigation for admin/agent roles
│       ├── shimmer_loading.dart     # ShimmerLoading, ShimmerBox — loading placeholders
│       ├── error_state.dart         # ErrorState widget with retry button
│       └── empty_state.dart         # EmptyState widget with icon + title
├── integration_test/                # (to be created — integration tests)
├── test/                            # (to be created — widget tests)
├── pubspec.yaml                     # Dependencies defined
└── pubspec.lock                     # Lock file
```

## Screens (9 files)

| Screen | File | Role Access | Description |
|--------|------|-------------|-------------|
| HomeScreen | `screens/home_screen.dart` | All | Public homepage (placeholder) |
| PropertyListScreen | `screens/property_list_screen.dart` | All | Property listing (placeholder) |
| AgencyListScreen | `screens/agency_list_screen.dart` | All | Agency listing (placeholder) |
| ProfileScreen | `screens/profile_screen.dart` | Authenticated | User profile (placeholder) |
| LoginScreen | `screens/login_screen.dart` | Unauthenticated | Login form (placeholder) |
| ClientDashboardScreen | `screens/client_dashboard_screen.dart` | CLIENT | Client dashboard (placeholder) |
| AdminDashboardScreen | `screens/admin/admin_dashboard_screen.dart` | ADMIN/AGENT | Admin dashboard (placeholder) |
| AdminBiensScreen | `screens/admin/admin_biens_screen.dart` | ADMIN/AGENT | Property management (placeholder) |
| AdminContratsScreen | `screens/admin/admin_contrats_screen.dart` | ADMIN/AGENT | Contract management (placeholder) |

## Widgets (5 files)

| Widget | File | Description |
|--------|------|-------------|
| AppShell | `widgets/app_shell.dart` | Main scaffold: public bottom nav (4 tabs) or admin bottom nav (4 tabs) + drawer |
| AdminDrawer | `widgets/admin_drawer.dart` | Drawer: Personnes, Utilisateurs, Agences, Références, Profil, Déconnexion |
| ShimmerLoading | `widgets/shimmer_loading.dart` | List shimmer loading placeholder |
| ShimmerBox | `widgets/shimmer_loading.dart` | Single box shimmer placeholder |
| ErrorState | `widgets/error_state.dart` | Error message with retry button |
| EmptyState | `widgets/empty_state.dart` | Empty state with icon and title |

## Models (0 files)

*To be implemented*

## Providers (1 file)

| Provider | File | State | Description |
|----------|------|-------|-------------|
| AuthProvider | `providers/auth_provider.dart` | isAuthenticated, role, nom, prenom, email, agenceId, agenceNom, personneId | Login/logout, JWT secure storage, role checks (isAdmin, isAgent, isClient, hasAdminNav) |

## Services (1 file)

| Service | File | Methods | Description |
|---------|------|---------|-------------|
| ApiService | `services/api_service.dart` | `login()`, `getBiens()`, `getBienById()` | Dio HTTP client with JWT token interceptor |

## Config (9 files)

| File | Class(es) | Description |
|------|-----------|-------------|
| `config/api_config.dart` | ApiConfig | Base URL, timeouts |
| `config/app_colors.dart` | AppColors, StatCardColors | 16 palette tokens, semantic colors, badges, stat variants, role colors |
| `config/app_text_styles.dart` | AppTextStyles, TextStyleX, AppTextComposed | 4 sizes, weight/color extensions, composed styles |
| `config/app_spacing.dart` | AppSpacing | 4px grid spacing constants |
| `config/app_radius.dart` | AppRadius | sm/md/lg/full border radius |
| `config/app_shadows.dart` | AppShadows | sm/md/lg/focusRing box shadows |
| `config/app_theme.dart` | AppTheme | Full ThemeData configuration |
| `config/app_formatters.dart` | AppFormatters | Currency, date, ID, area formatting |
| `config/app_icons.dart` | AppIconSizes | xs/sm/md/lg/xl icon sizes |

## Navigation Structure

### Public / Client (Bottom Navigation Bar)
| Tab | Icon | Screen |
|-----|------|--------|
| Accueil | home | HomeScreen |
| Biens | apartment | PropertyListScreen |
| Agences | location_on | AgencyListScreen |
| Profil/Connexion | person | ProfileScreen / LoginScreen |

### Admin / Agent (Bottom Nav + Drawer)
**Bottom Nav:**
| Tab | Icon | Screen |
|-----|------|--------|
| Tableau de bord | dashboard | AdminDashboardScreen |
| Biens | apartment | AdminBiensScreen |
| Contrats | description | AdminContratsScreen |
| Plus | more_horiz | Opens drawer |

**Drawer:**
| Item | Icon | Destination |
|------|------|-------------|
| Personnes | people | Placeholder |
| Utilisateurs | manage_accounts | Placeholder (admin only) |
| Agences | business | Placeholder |
| Données de référence | settings | Placeholder (super_admin only) |
| Profil | person | ProfileScreen |
| Déconnexion | logout | Logout |

## Dependencies (pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.4.0 | HTTP client |
| `provider` | ^6.1.1 | State management |
| `flutter_secure_storage` | ^9.0.0 | JWT token storage |
| `cached_network_image` | ^3.3.1 | Image caching |
| `image_picker` | ^1.0.7 | Photo uploads |
| `carousel_slider` | ^4.2.1 | Image carousels |
| `shimmer` | ^3.0.0 | Loading placeholders |
| `intl` | ^0.18.1 | Date/number formatting |
| `url_launcher` | ^6.2.4 | External links |

## Testing

- **Integration tests**: Android emulator on Windows + ADB bridge to WSL2
- **Setup guide**: `docs/FLUTTER_TESTING_SETUP.md`
- **Test type in spec system**: `flutter_integration`

---

## Update Triggers

Update this file when you:
- Add, rename, or delete a screen
- Add, rename, or delete a widget
- Add, rename, or delete a model
- Add, rename, or delete a provider
- Add or remove a service or change its methods
- Add or remove a dependency
