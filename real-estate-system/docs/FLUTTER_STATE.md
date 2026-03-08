# Flutter Mobile State

> **Owner**: Role 3 — Flutter Mobile
> **Rule**: Read this file at session start. Update it after any structural change (new screen, widget, provider, model, or service).

---

## Current Structure (Phase 3 — All 17 specs implemented)

```
frontend-mobile/
├── lib/
│   ├── main.dart                    # App entry point with Provider + AppTheme
│   ├── config/
│   │   ├── api_config.dart          # API base URL and timeout config
│   │   ├── app_colors.dart          # AppColors, StatCardColors
│   │   ├── app_text_styles.dart     # AppTextStyles, TextStyleX, AppTextComposed
│   │   ├── app_spacing.dart         # AppSpacing (4px grid)
│   │   ├── app_radius.dart          # AppRadius (sm/md/lg/full)
│   │   ├── app_shadows.dart         # AppShadows (sm/md/lg/focusRing)
│   │   ├── app_theme.dart           # AppTheme.build() — full ThemeData
│   │   ├── app_formatters.dart      # AppFormatters (currency, date, IDs, area)
│   │   └── app_icons.dart           # AppIconSizes (xs/sm/md/lg/xl)
│   ├── models/                      # (empty — raw maps used directly)
│   ├── providers/
│   │   └── auth_provider.dart       # AuthProvider — login, logout, role state, secure storage
│   ├── screens/
│   │   ├── home_screen.dart         # Homepage: hero, search, featured biens, agencies
│   │   ├── property_list_screen.dart # Biens list with filters, infinite scroll
│   │   ├── property_detail_screen.dart # Bien detail: carousel, chars, proximity, agency
│   │   ├── agency_list_screen.dart  # Agences list with search
│   │   ├── agency_detail_screen.dart # Agence detail: contact, properties
│   │   ├── profile_screen.dart      # User profile, password change, logout
│   │   ├── login_screen.dart        # Login form with validation
│   │   ├── activate_screen.dart     # Account activation with token
│   │   ├── forgot_password_screen.dart # Forgot password email form
│   │   ├── reset_password_screen.dart  # Reset password with token
│   │   ├── client_dashboard_screen.dart # Client dashboard: stats, biens, contrats
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart  # Admin dashboard: stats, quick actions, recent
│   │       ├── admin_biens_screen.dart      # Property list with CRUD actions
│   │       ├── admin_bien_form_screen.dart  # Property create/edit form
│   │       ├── admin_contrats_screen.dart   # Contract list with pagination
│   │       ├── admin_contrat_detail_screen.dart # Contract detail with cosigners
│   │       ├── admin_personnes_screen.dart  # Person list with search
│   │       ├── admin_personne_form_screen.dart # Person create/edit form
│   │       ├── admin_agences_screen.dart    # Agency list (SUPER_ADMIN CRUD)
│   │       ├── admin_agence_form_screen.dart # Agency create/edit form
│   │       ├── admin_users_screen.dart      # User list with deactivation
│   │       └── admin_references_screen.dart # Caractéristiques/Lieux CRUD tabs
│   ├── services/
│   │   └── api_service.dart         # Full API client (~75 methods)
│   └── widgets/
│       ├── app_shell.dart           # Main scaffold with role-adaptive nav
│       ├── admin_drawer.dart        # Admin drawer with logout confirmation
│       ├── shimmer_loading.dart     # ShimmerLoading, ShimmerBox
│       ├── error_state.dart         # ErrorState with retry
│       └── empty_state.dart         # EmptyState with icon/title
├── integration_test/                # (to be created)
├── test/                            # (to be created)
├── pubspec.yaml
└── pubspec.lock
```

## Screens (22 files)

| Screen | File | Spec | Description |
|--------|------|------|-------------|
| HomeScreen | `screens/home_screen.dart` | fm-public-homepage | Hero, search, featured properties, agencies |
| PropertyListScreen | `screens/property_list_screen.dart` | fm-public-property | Filterable, paginated property list |
| PropertyDetailScreen | `screens/property_detail_screen.dart` | fm-public-property | Photo carousel, characteristics, proximity |
| AgencyListScreen | `screens/agency_list_screen.dart` | fm-public-agence | Searchable agency list |
| AgencyDetailScreen | `screens/agency_detail_screen.dart` | fm-public-agence | Agency info, contact, properties |
| ProfileScreen | `screens/profile_screen.dart` | fm-user-profile | User info, password change, logout |
| LoginScreen | `screens/login_screen.dart` | fm-auth-login | Email/password login |
| ActivateScreen | `screens/activate_screen.dart` | fm-auth-activate | Account activation with token |
| ForgotPasswordScreen | `screens/forgot_password_screen.dart` | fm-auth-password-reset | Request reset email |
| ResetPasswordScreen | `screens/reset_password_screen.dart` | fm-auth-password-reset | Reset password with token |
| ClientDashboardScreen | `screens/client_dashboard_screen.dart` | fm-client-dashboard | Client stats, biens, contrats |
| AdminDashboardScreen | `screens/admin/admin_dashboard_screen.dart` | fm-admin-dashboard | Stats grid, quick actions, recent activity |
| AdminBiensScreen | `screens/admin/admin_biens_screen.dart` | fm-admin-bien | Property management list |
| AdminBienFormScreen | `screens/admin/admin_bien_form_screen.dart` | fm-admin-bien | Property create/edit form |
| AdminContratsScreen | `screens/admin/admin_contrats_screen.dart` | fm-admin-contrat | Contract list |
| AdminContratDetailScreen | `screens/admin/admin_contrat_detail_screen.dart` | fm-admin-contrat | Contract detail with cosigners |
| AdminPersonnesScreen | `screens/admin/admin_personnes_screen.dart` | fm-admin-personne | Person management list |
| AdminPersonneFormScreen | `screens/admin/admin_personne_form_screen.dart` | fm-admin-personne | Person create/edit form |
| AdminAgencesScreen | `screens/admin/admin_agences_screen.dart` | fm-admin-agence | Agency management |
| AdminAgenceFormScreen | `screens/admin/admin_agence_form_screen.dart` | fm-admin-agence | Agency create/edit form |
| AdminUsersScreen | `screens/admin/admin_users_screen.dart` | fm-admin-user | User management |
| AdminReferencesScreen | `screens/admin/admin_references_screen.dart` | fm-admin-reference | Reference data tabs |

## Widgets (5 files)

| Widget | File | Description |
|--------|------|-------------|
| AppShell | `widgets/app_shell.dart` | Main scaffold: public bottom nav or admin bottom nav + drawer |
| AdminDrawer | `widgets/admin_drawer.dart` | Drawer with logout confirmation |
| ShimmerLoading/ShimmerBox | `widgets/shimmer_loading.dart` | Loading placeholders |
| ErrorState | `widgets/error_state.dart` | Error with retry button |
| EmptyState | `widgets/empty_state.dart` | Empty state with icon |

## Providers (1 file)

| Provider | File | Description |
|----------|------|-------------|
| AuthProvider | `providers/auth_provider.dart` | Login/logout, JWT storage, role checks |

## Services (1 file)

| Service | File | Methods | Description |
|---------|------|---------|-------------|
| ApiService | `services/api_service.dart` | ~75 methods | Full API client: auth, biens, agences, personnes, contrats, utilisateurs, locations, achats, caractéristiques, lieux, client dashboard, profile |

## Config (9 files)

| File | Class(es) |
|------|-----------|
| `config/api_config.dart` | ApiConfig |
| `config/app_colors.dart` | AppColors, StatCardColors |
| `config/app_text_styles.dart` | AppTextStyles, TextStyleX, AppTextComposed |
| `config/app_spacing.dart` | AppSpacing |
| `config/app_radius.dart` | AppRadius |
| `config/app_shadows.dart` | AppShadows |
| `config/app_theme.dart` | AppTheme |
| `config/app_formatters.dart` | AppFormatters |
| `config/app_icons.dart` | AppIconSizes |

## Navigation Structure

### Public / Client (Bottom Navigation Bar)
| Tab | Screen |
|-----|--------|
| Accueil | HomeScreen |
| Biens | PropertyListScreen |
| Agences | AgencyListScreen |
| Profil/Connexion | ProfileScreen / LoginScreen |

### Admin / Agent (Bottom Nav + Drawer)
**Bottom Nav:** Tableau de bord, Biens, Contrats, Plus (opens drawer)
**Drawer:** Personnes, Utilisateurs, Agences, Références, Profil, Déconnexion

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
