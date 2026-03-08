# Flutter Integration Testing Setup: Windows PowerShell + Android Emulator

## Overview

Flutter integration tests run on a real Android emulator to validate UI flows end-to-end. In this project's setup:

- The **Android emulator** runs on **Windows** (via Android Studio).
- **Flutter SDK** is installed on **Windows** (`C:\tools\flutter`).
- **ADB** is on the Windows PATH (via Android SDK `platform-tools`).
- All Flutter and ADB commands run in **Windows PowerShell**, not WSL2.

### Why not WSL2?

The Flutter SDK uses Windows batch scripts (`.bat`) that cannot execute in WSL2's Linux environment. ADB TCP bridging between WSL2 and Windows is unreliable. Running Flutter natively on Windows where the emulator lives is the simplest and most stable approach.

### Testing Agent workflow

Since the Testing Agent runs inside WSL2 (via Claude Code) but cannot execute Flutter commands directly:

1. The Testing Agent **generates the exact PowerShell commands** to run.
2. The **user executes them in Windows PowerShell** and pastes the output back.
3. The Testing Agent **parses the output** and updates spec status accordingly.

---

## Prerequisites

### Windows

- **Android Studio** installed with the Android SDK.
- **Android SDK Command-line Tools** installed (Android Studio > Settings > SDK Tools).
- **Android licenses accepted**: `flutter doctor --android-licenses`
- At least one **AVD (Android Virtual Device)** created.
- **ADB** on PATH: Add `C:\Users\<username>\AppData\Local\Android\Sdk\platform-tools` to the `Path` environment variable (System > Environment Variables > Edit `Path` > New).
- **Flutter SDK** on PATH: `C:\tools\flutter\bin` (or wherever Flutter is installed).

### Verification

Open **Windows PowerShell** and confirm:

```powershell
flutter --version    # Should show Flutter 3.41+ with Dart 3.11+
adb devices          # Should show emulator-5554 (when emulator is running)
flutter devices      # Should list the emulator as a connected device
```

---

## Step-by-step Setup

### 1. Create and Start the Android Emulator

1. Open **Android Studio** > **Device Manager** (or Tools > Device Manager).
2. Click **Create Virtual Device**.
3. Select a device profile: **Pixel 7** (recommended).
4. Select a system image: **API 34 (Android 14)** with Google APIs, x86_64.
5. Finish the wizard and **start the emulator** by clicking the Play button.
6. Verify in PowerShell:
   ```powershell
   adb devices
   ```
   Expected:
   ```
   List of devices attached
   emulator-5554   device
   ```

### 2. Authorize the Emulator

If `adb devices` shows `unauthorized`:
1. Look for a popup on the emulator asking "Allow USB debugging?" and tap **Allow**.
2. If no popup appears, in the emulator go to **Settings > Developer options**, toggle **USB debugging** off then on.
3. If still unauthorized:
   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

### 3. Verify Flutter Sees the Device

```powershell
flutter devices
```

Expected:
```
Found 2 connected devices:
  sdk gphone64 x86 64 (mobile) * emulator-5554 * android-x64 * Android 14 (API 34) (emulator)
  Windows (desktop)            * windows       * windows-x64 * Microsoft Windows [...]
```

The emulator device ID is `emulator-5554`.

---

## Integration Test File Structure

```
frontend-mobile/
├── integration_test/              # Integration tests (run on device/emulator)
│   ├── auth_test.dart             # Authentication flow tests (login, logout, activate, password reset)
│   ├── public_test.dart           # Public screens (home, property list/detail, agency list/detail)
│   ├── layout_test.dart           # App navigation and layout structure
│   ├── client_test.dart           # Client dashboard
│   ├── profile_test.dart          # User profile screen
│   ├── admin_dashboard_test.dart  # Admin dashboard
│   ├── admin_bien_test.dart       # Admin property CRUD
│   ├── admin_agence_test.dart     # Admin agency CRUD
│   ├── admin_contrat_test.dart    # Admin contract screens
│   ├── admin_personne_test.dart   # Admin person CRUD
│   ├── admin_user_test.dart       # Admin user management
│   └── admin_reference_test.dart  # Admin reference data
├── test/
│   └── widget_test.dart           # Widget unit tests (no device needed)
└── pubspec.yaml                   # Must include integration_test dependency
```

**Note:** `test_driver/` is NOT needed for Android/iOS device testing. It is only required for web browser testing via ChromeDriver. See [official docs](https://docs.flutter.dev/testing/integration-tests).

### pubspec.yaml Dependencies

Ensure `pubspec.yaml` includes:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

To add via CLI: `flutter pub add "dev:integration_test:{sdk: flutter}"`

---

## Running Integration Tests

All commands run in **Windows PowerShell**, from the project directory:

```powershell
cd C:\Users\frant\Documents\GitHub\Horoazhon\real-estate-system\frontend-mobile

# Run all integration tests on the emulator
flutter test integration_test/ -d emulator-5554

# Run a specific test file
flutter test integration_test/auth_test.dart -d emulator-5554

# Run with verbose output (useful for debugging)
flutter test integration_test/auth_test.dart -d emulator-5554 --verbose
```

If only one mobile device is connected, you can omit `-d`:

```powershell
flutter test integration_test/
```

---

## Writing Integration Tests

### Widget Finding Strategy

The app's screens use private `_formKey` variables for form validation, which are not accessible from integration tests. Use these finders instead:

| Finder | Use for | Example |
|--------|---------|---------|
| `find.byType(T)` | Find widgets by type | `find.byType(TextFormField)` |
| `find.text('...')` | Find exact text | `find.text('Se connecter')` |
| `find.textContaining('...')` | Find partial text | `find.textContaining('Identifiants')` |
| `find.byIcon(Icons.x)` | Find by icon | `find.byIcon(Icons.email)` |
| `find.widgetWithText(T, '...')` | Find widget type containing text | `find.widgetWithText(ElevatedButton, 'Se connecter')` |
| `find.byType(T).at(n)` | Find nth widget of type | `find.byType(TextFormField).at(1)` |

**Important:** `find.byKey()` will NOT work unless public `Key()` or `ValueKey()` constants are added to the app widgets. When multiple `TextFormField` widgets exist on a screen, use positional indexing (`.at(0)`, `.at(1)`) or `find.widgetWithText()` to distinguish them.

### Complete Example: Login Flow

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication', () {
    testWidgets('Login with valid credentials navigates to dashboard',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login screen (tap Profil tab if on home)
      final profilTab = find.text('Profil');
      if (profilTab.evaluate().isNotEmpty) {
        await tester.tap(profilTab);
        await tester.pumpAndSettle();
      }

      // Find form fields by type and position
      // Login screen has 2 TextFormFields: email (0), password (1)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'admin@horoazhon.fr');
      await tester.enterText(textFields.at(1), 'Admin');

      // Tap login button by its text
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));

      // Wait for API response and navigation
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we reached the admin dashboard
      expect(find.text('Tableau de bord'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login if needed
      final profilTab = find.text('Profil');
      if (profilTab.evaluate().isNotEmpty) {
        await tester.tap(profilTab);
        await tester.pumpAndSettle();
      }

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'wrong@email.com');
      await tester.enterText(textFields.at(1), 'wrongpassword');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify error message is displayed
      expect(find.textContaining('Identifiants invalides'), findsOneWidget);
    });
  });
}
```

### Key Testing Patterns

**Waiting for async operations** (API calls, animations):
```dart
// pumpAndSettle waits until all animations and frames are done
await tester.pumpAndSettle(const Duration(seconds: 5));

// For specific conditions, use pump in a loop
for (int i = 0; i < 50; i++) {
  await tester.pump(const Duration(milliseconds: 100));
  if (find.text('Expected text').evaluate().isNotEmpty) break;
}
```

**Scrolling to find elements**:
```dart
await tester.scrollUntilVisible(
  find.text('Target text'),
  200.0,  // scroll delta
  scrollable: find.byType(Scrollable).first,
);
```

**Interacting with dropdowns**:
```dart
// Tap the dropdown by its type or label text
await tester.tap(find.byType(DropdownButtonFormField<String>));
await tester.pumpAndSettle();
await tester.tap(find.text('Appartement').last);
await tester.pumpAndSettle();
```

**Taking screenshots** (useful for debugging failures):
```dart
final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
await binding.takeScreenshot('login-page');
```

**Finding the nth widget of the same type**:
```dart
// When a screen has multiple TextFormFields, use positional index
final fields = find.byType(TextFormField);
await tester.enterText(fields.at(0), 'email@test.com');  // first field
await tester.enterText(fields.at(1), 'password123');      // second field
await tester.enterText(fields.at(2), 'password123');      // third field (confirm)
```

---

## Testing Agent Protocol

The Testing Agent runs inside WSL2 (via Claude Code) and **cannot execute Flutter commands directly**. Instead, it uses a user-assisted workflow.

### Two-Phase Workflow

**Phase 1: Writing Tests (QA Agent — runs in WSL2)**
- QA reads feature specs and Flutter source code
- QA writes Dart test files in `integration_test/` (creates files via Write tool)
- QA writes JSON spec entries via `spec_helper.py write-test` (for spec tracking)
- No emulator or Flutter SDK needed for this phase

**Phase 2: Running Tests (Testing Agent — user-assisted)**
- Testing Agent generates PowerShell commands
- User runs them on Windows and pastes output back
- Testing Agent parses results and updates spec status

### Pre-flight Check

The Testing Agent asks the user to confirm the emulator is running:
```
Please confirm the Android emulator is running:
1. Open Android Studio > Device Manager > Start emulator
2. In PowerShell, run: flutter devices
3. Confirm the emulator appears (emulator-5554)
```

### Test Execution (User-Assisted)

1. The Testing Agent generates the exact command(s) to run.
2. The user executes them in **Windows PowerShell** and pastes the output.
3. The Testing Agent parses the output and updates spec results.

Example interaction:

**Testing Agent says:**
```
Please run this in Windows PowerShell:

cd C:\Users\frant\Documents\GitHub\Horoazhon\real-estate-system\frontend-mobile
flutter test integration_test/auth_test.dart -d emulator-5554

Paste the full output back here.
```

**User pastes:**
```
00:05 +2: All tests passed!
```

**Testing Agent updates** the spec status to `passing`.

### Parsing Results

Flutter test output follows this pattern:
```
00:05 +2: All tests passed!          # Success
00:12 +1 -1: Some tests failed.      # Failure with details above
```

The Testing Agent:
- Parses `+N` as passed test count.
- Parses `-N` as failed test count.
- Captures failure messages (printed above the summary line) as `lastResult`.

### Database Reset

For Flutter integration tests that hit the backend API, the Testing Agent resets the database before running (same as HTTP tests):
- Run `/reset-db` from WSL2 before each feature's test suites
- Wait for backend health check before asking the user to run tests

---

## Troubleshooting

### Device shows "unauthorized"

**Symptom**: `adb devices` shows `emulator-5554  unauthorized`.

**Fix**:
1. Check the emulator for an "Allow USB debugging?" dialog.
2. Toggle Developer options > USB debugging off and on.
3. Restart ADB:
   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

### Emulator not found by Flutter

**Symptom**: `flutter devices` shows no mobile devices, but `adb devices` shows connected.

**Fix**:
```powershell
flutter doctor -v
```

Common causes:
- Android SDK Command-line Tools not installed (install via Android Studio > Settings > SDK Tools).
- Licenses not accepted: `flutter doctor --android-licenses`

### Gradle build fails

**Symptom**: `flutter test` fails during the build step with Gradle errors.

**Fix**:
```powershell
cd C:\Users\frant\Documents\GitHub\Horoazhon\real-estate-system\frontend-mobile
flutter clean
flutter pub get
flutter test integration_test/
```

### Tests hang or timeout

**Symptom**: Tests start but never complete.

**Fix**:
- Ensure the backend API is running and reachable from the emulator. The emulator uses `10.0.2.2` to reach the host machine's `localhost`:
  ```dart
  // In your API config for testing, use:
  const apiBaseUrl = 'http://10.0.2.2:8080';
  ```
- Increase `pumpAndSettle` timeouts:
  ```dart
  await tester.pumpAndSettle(const Duration(seconds: 10));
  ```
- Check if a dialog or permission prompt is blocking the UI.

### Build cache issues after Flutter upgrade

**Symptom**: Build errors after upgrading Flutter.

**Fix**:
```powershell
flutter clean
flutter pub get
# Delete Gradle cache if needed
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"
```

---

## CI/CD Considerations

This guide covers **local development and local Testing Agent sessions**. For CI/CD environments where a physical emulator is not available:

- **Firebase Test Lab**: Upload your APK and test suite to run on real cloud-hosted devices:
  ```powershell
  # Build the test APK
  cd android
  flutter build apk
  .\gradlew app:assembleAndroidTest
  cd ..

  # Upload to Firebase Test Lab
  gcloud firebase test android run `
    --type instrumentation `
    --app build/app/outputs/apk/debug/app-debug.apk `
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk
  ```

- **GitHub Actions with Android emulator**: Use `reactivecircus/android-emulator-runner` action to spin up an emulator in CI:
  ```yaml
  - name: Run integration tests
    uses: reactivecircus/android-emulator-runner@v2
    with:
      api-level: 34
      script: flutter test integration_test/
  ```

---

## Quick Reference

| Task | Command (PowerShell) |
|------|----------------------|
| Start emulator | Android Studio > Device Manager > Play |
| Check ADB devices | `adb devices` |
| Check Flutter devices | `flutter devices` |
| Add integration_test dep | `flutter pub add "dev:integration_test:{sdk: flutter}"` |
| Run all integration tests | `flutter test integration_test/ -d emulator-5554` |
| Run one test file | `flutter test integration_test/auth_test.dart -d emulator-5554` |
| Run with verbose output | `flutter test integration_test/auth_test.dart -d emulator-5554 --verbose` |
| Clean build | `flutter clean; flutter pub get` |
| Accept licenses | `flutter doctor --android-licenses` |
| Diagnose issues | `flutter doctor -v` |

## Test File ↔ Feature Mapping

| Test file | Features covered |
|-----------|-----------------|
| `auth_test.dart` | fm-auth-login, fm-auth-logout, fm-auth-activate, fm-auth-password-reset |
| `public_test.dart` | fm-public-homepage, fm-public-property, fm-public-agence |
| `layout_test.dart` | fm-layout |
| `client_test.dart` | fm-client-dashboard |
| `profile_test.dart` | fm-user-profile |
| `admin_dashboard_test.dart` | fm-admin-dashboard |
| `admin_bien_test.dart` | fm-admin-bien |
| `admin_agence_test.dart` | fm-admin-agence |
| `admin_contrat_test.dart` | fm-admin-contrat |
| `admin_personne_test.dart` | fm-admin-personne |
| `admin_user_test.dart` | fm-admin-user |
| `admin_reference_test.dart` | fm-admin-reference |
