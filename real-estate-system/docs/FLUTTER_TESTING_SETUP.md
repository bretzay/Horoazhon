# Flutter Integration Testing Setup: Android Emulator on Windows + WSL2

## Overview

Flutter integration tests run on a real Android emulator to validate UI flows end-to-end. In this project's setup:

- The **Android emulator** runs on **Windows** (via Android Studio).
- **WSL2** connects to the emulator over TCP using **ADB** (Android Debug Bridge).
- The **Testing Agent** (running inside WSL2) executes `flutter test integration_test/` targeting the emulator.

This architecture allows the full Flutter test suite to run from the Linux environment where the development toolchain lives, while leveraging the Windows-hosted emulator for device rendering.

---

## Prerequisites

### Windows

- **Android Studio** installed with the Android SDK.
- At least one **AVD (Android Virtual Device)** created (see Step 1 below).
- **ADB** available on PATH (installed with Android Studio under `<SDK>/platform-tools/`).

### WSL2

- **Flutter SDK** installed and on PATH (`flutter doctor` passes).
- **ADB** installed:
  ```bash
  # Option A: Ubuntu/Debian package
  sudo apt install adb

  # Option B: Use the Android SDK's platform-tools (if SDK is installed in WSL2)
  export PATH="$PATH:$HOME/Android/Sdk/platform-tools"
  ```
- **Java** (required by Flutter/Gradle): OpenJDK 17+.

### Network

- WSL2 must be able to reach the Windows host IP on port 5555.
- Windows Firewall must allow inbound connections on port 5555 from WSL2.

---

## Step-by-step Setup

### 1. Windows Side: Create and Start the Android Emulator

1. Open **Android Studio** > **Device Manager** (or Tools > Device Manager).
2. Click **Create Virtual Device**.
3. Select a device profile: **Pixel 7** (recommended).
4. Select a system image: **API 34 (Android 14)** with Google APIs, x86_64.
5. Finish the wizard and **start the emulator** by clicking the Play button.
6. Verify the emulator appears in ADB. Open **Windows PowerShell** or **Command Prompt**:
   ```powershell
   adb devices
   ```
   You should see something like:
   ```
   List of devices attached
   emulator-5554   device
   ```

### 2. Windows Side: Enable ADB over TCP

By default, ADB communicates with the emulator over USB/local socket. To allow WSL2 to connect, switch ADB to TCP mode.

In **Windows PowerShell** or **Command Prompt**:

```powershell
adb tcpip 5555
```

Expected output:
```
restarting in TCP mode port: 5555
```

This tells the ADB daemon on the emulator to also listen on TCP port 5555.

### 3. Find the Windows Host IP from WSL2

WSL2 runs in a lightweight VM with its own network namespace. You need the Windows host IP to bridge the connection.

```bash
# Method 1: /etc/resolv.conf (most reliable on standard WSL2 setups)
WIN_HOST=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo $WIN_HOST

# Method 2: Default gateway (works on most WSL2 configurations)
WIN_HOST=$(ip route show default | awk '{print $3}')
echo $WIN_HOST
```

Either method should return an IP like `172.x.x.x`. Save this value for the next step.

### 4. WSL2 Side: Connect ADB to the Windows Emulator

```bash
# Set the Windows host IP (use the method from Step 3)
WIN_HOST=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# Kill any existing ADB server in WSL2 to avoid conflicts
adb kill-server

# Connect to the Windows emulator over TCP
adb connect $WIN_HOST:5555
```

Expected output:
```
connected to 172.x.x.x:5555
```

Verify the connection:

```bash
adb devices
```

Expected output:
```
List of devices attached
172.x.x.x:5555    device
```

If the status shows `offline` instead of `device`, see the Troubleshooting section.

### 5. Verify Flutter Sees the Device

```bash
flutter devices
```

Expected output should include the emulator:
```
Found 1 connected device:
  sdk gphone64 x86 64 (mobile) * 172.x.x.x:5555 * android-x64 * Android 14 (API 34)
```

Note the device ID (`172.x.x.x:5555` or similar) -- you will use this with the `-d` flag.

---

## Integration Test File Structure

```
frontend-mobile/
├── integration_test/              # Integration tests (run on device/emulator)
│   ├── app_test.dart              # Main test runner / smoke tests
│   ├── auth_test.dart             # Authentication flow tests
│   ├── property_test.dart         # Property browsing and search tests
│   └── admin_test.dart            # Admin CRUD operation tests
├── test_driver/
│   └── integration_test.dart      # Test driver boilerplate
├── test/
│   └── widget_test.dart           # Widget unit tests (no device needed)
└── pubspec.yaml                   # Must include integration_test dependency
```

### pubspec.yaml Dependencies

Ensure `pubspec.yaml` includes:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

### Test Driver Boilerplate

Create `test_driver/integration_test.dart`:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

---

## Running Integration Tests

```bash
cd real-estate-system/frontend-mobile

# Get the device ID
DEVICE_ID=$(flutter devices | grep android | awk '{print $5}')

# Run all integration tests
flutter test integration_test/ -d $DEVICE_ID

# Run a specific test file
flutter test integration_test/auth_test.dart -d $DEVICE_ID

# Run with verbose output (useful for debugging)
flutter test integration_test/auth_test.dart -d $DEVICE_ID --verbose
```

If only one device is connected, you can omit `-d`:

```bash
flutter test integration_test/
```

---

## Writing Integration Tests

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

      // Fill in email
      final emailField = find.byKey(const Key('email_field'));
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, 'admin@horoazhon.fr');

      // Fill in password
      final passwordField = find.byKey(const Key('password_field'));
      await tester.enterText(passwordField, 'Admin');

      // Tap the login button
      final loginButton = find.byKey(const Key('login_button'));
      await tester.tap(loginButton);

      // Wait for navigation and API response
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify we reached the dashboard
      expect(find.text('Tableau de bord'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('email_field')), 'wrong@email.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify error message is displayed
      expect(find.textContaining('Identifiants incorrects'), findsOneWidget);
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
await tester.tap(find.byKey(const Key('type_dropdown')));
await tester.pumpAndSettle();
await tester.tap(find.text('Appartement').last);
await tester.pumpAndSettle();
```

**Taking screenshots** (useful for debugging failures):
```dart
final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
await binding.takeScreenshot('login-page');
```

---

## Testing Agent Protocol

When the Testing Agent (running in WSL2) needs to execute Flutter integration tests:

### Pre-flight Checks

1. **Verify emulator is connected**:
   ```bash
   adb devices
   ```
   Must show a device with status `device` (not `offline` or `unauthorized`).

2. **If not connected**, the Testing Agent **cannot start the emulator** from WSL2. It must report:
   ```
   BLOCKED: No Android emulator connected.
   Action required: Start the emulator from Windows Android Studio,
   then run "adb tcpip 5555" in Windows terminal.
   From WSL2, run: adb connect <windows-host-ip>:5555
   ```

3. **Verify Flutter sees the device**:
   ```bash
   flutter devices
   ```

### Test Execution

```bash
cd real-estate-system/frontend-mobile
flutter test integration_test/<file>.dart 2>&1
```

### Parsing Results

Flutter test output follows this pattern:
```
00:05 +2: All tests passed!          # Success
00:12 +1 -1: Some tests failed.      # Failure with details above
```

The Testing Agent should:
- Parse `+N` as passed test count.
- Parse `-N` as failed test count.
- Capture failure messages (printed above the summary line) as `lastResult`.

### Spec System Integration

A new test type `"flutter_integration"` should be used in spec test files for Flutter-specific tests. This distinguishes them from `"http"` (backend API) and `"browser"` (Puppeteer web) tests.

Example test suite entry in a future `frontend-mobile-tests.json`:
```json
{
  "id": "fm-auth-login-test-1",
  "featureId": "fm-auth-login",
  "title": "Valid login navigates to dashboard",
  "type": "flutter_integration",
  "testFile": "integration_test/auth_test.dart",
  "status": "not_tested",
  "lastResult": null
}
```

---

## Troubleshooting

### ADB connection refused

**Symptom**: `adb connect` returns `failed to connect`.

**Fix**:
1. Ensure the emulator is running on Windows.
2. Run `adb tcpip 5555` from Windows (not WSL2).
3. Check Windows Firewall: allow inbound TCP on port 5555.
   - Windows Settings > Firewall > Advanced Settings > Inbound Rules > New Rule
   - Port: 5555, TCP, Allow the connection.

### Device shows "offline"

**Symptom**: `adb devices` shows `<ip>:5555  offline`.

**Fix**:
```bash
# In WSL2
adb disconnect
adb kill-server
adb connect $WIN_HOST:5555
```

If it persists, restart ADB on the Windows side too:
```powershell
# In Windows PowerShell
adb kill-server
adb start-server
adb tcpip 5555
```

### Emulator not found by Flutter

**Symptom**: `flutter devices` shows no devices, but `adb devices` shows connected.

**Fix**:
```bash
flutter doctor
```

Common causes:
- Flutter SDK not configured for Android: run `flutter config --android-sdk <path>`.
- ADB version mismatch between Flutter's bundled ADB and system ADB. Use the same ADB binary:
  ```bash
  export PATH="$HOME/Android/Sdk/platform-tools:$PATH"
  ```

### WSL2 cannot reach Windows host IP

**Symptom**: `ping $WIN_HOST` times out.

**Fix**:
1. Restart WSL2:
   ```powershell
   # In Windows PowerShell
   wsl --shutdown
   ```
   Then reopen your WSL2 terminal.
2. Check if the IP changed (it can change after WSL restarts):
   ```bash
   cat /etc/resolv.conf | grep nameserver
   ```
3. If using a VPN, it may interfere with WSL2 networking. Disconnect the VPN and retry.

### Gradle build fails

**Symptom**: `flutter test` fails during the build step with Gradle errors.

**Fix**:
```bash
cd real-estate-system/frontend-mobile/android
./gradlew clean
cd ..
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

### Port 5555 already in use

**Symptom**: `adb tcpip 5555` fails or conflicts.

**Fix**: Use a different port:
```powershell
# Windows
adb tcpip 5556
```
```bash
# WSL2
adb connect $WIN_HOST:5556
```

---

## CI/CD Considerations

This guide covers **local development and local Testing Agent sessions**. For CI/CD environments where a physical emulator is not available:

- **Headless Chrome**: Flutter supports running integration tests in a headless browser as a fallback:
  ```bash
  flutter test integration_test/ -d chrome --headless
  ```
  This does not test native Android behavior but covers UI logic.

- **Firebase Test Lab**: Upload your APK and test suite to run on real cloud-hosted devices:
  ```bash
  # Build the test APK
  pushd android
  flutter build apk
  ./gradlew app:assembleAndroidTest
  popd

  # Upload to Firebase Test Lab
  gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/apk/debug/app-debug.apk \
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

| Task | Command |
|------|---------|
| Start emulator (Windows) | Android Studio > Device Manager > Play |
| Enable TCP ADB (Windows) | `adb tcpip 5555` |
| Get Windows IP (WSL2) | `cat /etc/resolv.conf \| grep nameserver \| awk '{print $2}'` |
| Connect ADB (WSL2) | `adb connect <WIN_IP>:5555` |
| Check devices | `adb devices` |
| Check Flutter devices | `flutter devices` |
| Run all integration tests | `flutter test integration_test/` |
| Run one test file | `flutter test integration_test/auth_test.dart` |
| Clean build | `flutter clean && flutter pub get` |
