# Flutter Mobile State

> **Owner**: Role 3 — Flutter Mobile
> **Rule**: Read this file at session start. Update it after any structural change (new screen, widget, provider, model, or service).

---

## Current Structure (Phase 3 — Initial)

```
frontend-mobile/
├── lib/
│   ├── main.dart                    # App entry point (basic MaterialApp placeholder)
│   ├── config/
│   │   └── api_config.dart          # API base URL and timeout config
│   ├── models/                      # (empty — models to be created)
│   ├── providers/                   # (empty — Provider state management)
│   ├── screens/                     # (empty — screen widgets)
│   ├── services/
│   │   └── api_service.dart         # Dio HTTP client with JWT interceptor (login + getBiens only)
│   └── widgets/                     # (empty — reusable widgets)
├── integration_test/                # (to be created — integration tests)
├── test/                            # (to be created — widget tests)
├── pubspec.yaml                     # Dependencies defined
└── pubspec.lock                     # Lock file
```

## Screens (0 files)

*To be implemented in Phase 3*

## Widgets (0 files)

*To be implemented in Phase 3*

## Models (0 files)

*To be implemented in Phase 3*

## Providers (0 files)

*To be implemented in Phase 3*

## Services (1 file)

| Service | File | Methods | Description |
|---------|------|---------|-------------|
| `ApiService` | `services/api_service.dart` | `login()`, `getBiens()`, `getBienById()` | Dio HTTP client with JWT token interceptor. Only 3 of ~75 API methods implemented. |

## Config (1 file)

| File | Contents |
|------|----------|
| `config/api_config.dart` | `baseUrl` (localhost:8080/api), `connectionTimeout` (30s), `receiveTimeout` (30s) |

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
