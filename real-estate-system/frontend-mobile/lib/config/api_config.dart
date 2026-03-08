import 'dart:io' show Platform;

class ApiConfig {
  // Android emulator uses 10.0.2.2 to reach host machine's localhost.
  // Override with --dart-define=API_HOST=<ip> for physical devices or custom setups.
  static const String _hostOverride = String.fromEnvironment('API_HOST');

  static String get baseUrl {
    if (_hostOverride.isNotEmpty) {
      return 'http://$_hostOverride:8080/api';
    }
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:8080/api';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}