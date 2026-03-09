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
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  // --- Auth ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    if (response.data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: response.data['token']);
    }
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> activateAccount(String token, String password) async {
    final response = await _dio.post(
      '/auth/activate',
      data: {'token': token, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkActivationStatus(String token) async {
    final response = await _dio.get('/auth/activation-status', queryParameters: {'token': token});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post('/auth/forgot-password', data: {'email': email});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkResetStatus(String token) async {
    final response = await _dio.get('/auth/reset-status', queryParameters: {'token': token});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    final response = await _dio.post(
      '/auth/reset-password',
      data: {'token': token, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> inviteClient({
    required int personneId,
    required String email,
    int? agenceId,
  }) async {
    final response = await _dio.post('/auth/invite-client', data: {
      'personneId': personneId,
      'email': email,
      if (agenceId != null) 'agenceId': agenceId,
    });
    return response.data as Map<String, dynamic>;
  }

  // --- Biens ---

  Future<Map<String, dynamic>> getBiens({
    String? search,
    String? type,
    double? prixMin,
    double? prixMax,
    bool? forSale,
    bool? forRent,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get('/biens', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null) 'type': type,
      if (prixMin != null) 'prixMin': prixMin,
      if (prixMax != null) 'prixMax': prixMax,
      if (forSale != null) 'forSale': forSale,
      if (forRent != null) 'forRent': forRent,
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBienById(int id) async {
    final response = await _dio.get('/biens/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createBien(Map<String, dynamic> data) async {
    final response = await _dio.post('/biens', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBien(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/biens/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteBien(int id) async {
    await _dio.delete('/biens/$id');
  }

  // --- Agences ---

  Future<List<dynamic>> getAgences() async {
    final response = await _dio.get('/agences');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getAgenceById(int id) async {
    final response = await _dio.get('/agences/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAgenceBiens(int agenceId, {int page = 0, int size = 10}) async {
    final response = await _dio.get('/agences/$agenceId/biens', queryParameters: {
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAgence(Map<String, dynamic> data) async {
    final response = await _dio.post('/agences', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAgence(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/agences/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteAgence(int id) async {
    await _dio.delete('/agences/$id');
  }

  // --- Personnes ---

  Future<List<dynamic>> getPersonnes() async {
    final response = await _dio.get('/personnes');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getPersonneById(int id) async {
    final response = await _dio.get('/personnes/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> searchPersonnes(String query) async {
    final response = await _dio.get('/personnes/search', queryParameters: {'q': query});
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createPersonne(Map<String, dynamic> data) async {
    final response = await _dio.post('/personnes', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePersonne(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/personnes/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deletePersonne(int id) async {
    await _dio.delete('/personnes/$id');
  }

  Future<Map<String, dynamic>> getPersonneAccountStatus(int id) async {
    final response = await _dio.get('/personnes/$id/account-status');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPersonneBiens(int id) async {
    final response = await _dio.get('/personnes/$id/biens');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getPersonneContrats(int id) async {
    final response = await _dio.get('/personnes/$id/contrats');
    return response.data as List<dynamic>;
  }

  // --- Contrats ---

  Future<Map<String, dynamic>> getContrats({int page = 0, int size = 10}) async {
    final response = await _dio.get('/contrats', queryParameters: {
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getContratById(int id) async {
    final response = await _dio.get('/contrats/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createContrat(Map<String, dynamic> data) async {
    final response = await _dio.post('/contrats', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateContrat(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/contrats/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteContrat(int id) async {
    await _dio.delete('/contrats/$id');
  }

  // --- Utilisateurs ---

  Future<List<dynamic>> getUtilisateurs() async {
    final response = await _dio.get('/users');
    final data = response.data as Map<String, dynamic>;
    return data['content'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getUtilisateurById(int id) async {
    final response = await _dio.get('/users/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUtilisateurRole(int id, String role) async {
    final response = await _dio.put('/users/$id/role', data: {'role': role});
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteUtilisateur(int id) async {
    await _dio.delete('/users/$id');
  }

  // --- Locations ---

  Future<Map<String, dynamic>> getLocations({int page = 0, int size = 10}) async {
    final response = await _dio.get('/locations', queryParameters: {
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createLocation(Map<String, dynamic> data) async {
    final response = await _dio.post('/locations', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateLocation(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/locations/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteLocation(int id) async {
    await _dio.delete('/locations/$id');
  }

  // --- Achats ---

  Future<Map<String, dynamic>> getAchats({int page = 0, int size = 10}) async {
    final response = await _dio.get('/achats', queryParameters: {
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAchat(Map<String, dynamic> data) async {
    final response = await _dio.post('/achats', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAchat(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/achats/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteAchat(int id) async {
    await _dio.delete('/achats/$id');
  }

  // --- Bien Caractéristiques (Property-level) ---

  Future<void> addBienCaracteristique(int bienId, int caracId, String valeur, {String? unite}) async {
    await _dio.post('/biens/$bienId/caracteristiques', queryParameters: {
      'caracteristiqueId': caracId,
      'valeur': valeur,
      if (unite != null) 'unite': unite,
    });
  }

  Future<void> removeBienCaracteristique(int bienId, int caracId) async {
    await _dio.delete('/biens/$bienId/caracteristiques/$caracId');
  }

  // --- Bien Lieux (Property-level) ---

  Future<void> addBienLieu(int bienId, int lieuId, int minutes, {String? typeLocomotion}) async {
    await _dio.post('/biens/$bienId/lieux', queryParameters: {
      'lieuId': lieuId,
      'minutes': minutes,
      if (typeLocomotion != null) 'typeLocomotion': typeLocomotion,
    });
  }

  Future<void> removeBienLieu(int bienId, int lieuId) async {
    await _dio.delete('/biens/$bienId/lieux/$lieuId');
  }

  // --- Caractéristiques (Reference Data) ---

  Future<List<dynamic>> getCaracteristiques() async {
    final response = await _dio.get('/caracteristiques');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createCaracteristique(Map<String, dynamic> data) async {
    final response = await _dio.post('/caracteristiques', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCaracteristique(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/caracteristiques/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteCaracteristique(int id) async {
    await _dio.delete('/caracteristiques/$id');
  }

  // --- Lieux (Reference Data) ---

  Future<List<dynamic>> getLieux() async {
    final response = await _dio.get('/lieux');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createLieu(Map<String, dynamic> data) async {
    final response = await _dio.post('/lieux', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateLieu(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('/lieux/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteLieu(int id) async {
    await _dio.delete('/lieux/$id');
  }

  // --- Client Dashboard ---

  Future<Map<String, dynamic>> getClientBiens({int page = 0, int size = 10}) async {
    final response = await _dio.get('/client/biens', queryParameters: {
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getClientContrats({int page = 0, int size = 10}) async {
    final response = await _dio.get('/client/contrats', queryParameters: {
      'page': page,
      'size': size,
    });
    return response.data as Map<String, dynamic>;
  }

  // --- Profil ---

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/auth/me', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.put('/auth/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
