import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectionTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        print('API Error: \${error.message}');
        return handler.next(error);
      },
    ));
  }

  Future<List<dynamic>> getBiens({
    String? ville,
    String? type,
    double? prixMin,
    double? prixMax,
    bool? forSale,
    bool? forRent,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/biens',
      queryParameters: {
        if (ville != null) 'ville': ville,
        if (type != null) 'type': type,
        if (prixMin != null) 'prixMin': prixMin,
        if (prixMax != null) 'prixMax': prixMax,
        if (forSale != null) 'forSale': forSale,
        if (forRent != null) 'forRent': forRent,
        'page': page,
        'size': size,
      },
    );
    
    return response.data['content'] as List;
  }

  Future<Map<String, dynamic>> getBienById(int id) async {
    final response = await _dio.get('/biens/\$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: response.data['token']);
    }
    
    return response.data as Map<String, dynamic>;
  }
}