class ApiConfig {
  // Change this to your computer's IP address for testing on physical devices
  // Use 'localhost' for emulator/simulator
  static const String baseUrl = 'http://localhost:8080/api';
  
  // For production, this will be replaced with remote server URL
  // static const String baseUrl = 'https://your-domain.com/api';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}