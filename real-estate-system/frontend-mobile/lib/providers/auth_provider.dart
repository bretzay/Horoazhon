import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  String? _role;
  String? _nom;
  String? _prenom;
  String? _email;
  int? _agenceId;
  String? _agenceNom;
  String? _agenceLogo;
  int? _personneId;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get role => _role;
  String? get nom => _nom;
  String? get prenom => _prenom;
  String? get email => _email;
  int? get agenceId => _agenceId;
  String? get agenceNom => _agenceNom;
  String? get agenceLogo => _agenceLogo;
  int? get personneId => _personneId;

  String get fullName => '${_prenom ?? ''} ${_nom ?? ''}'.trim();

  bool get isAdmin => _role == 'SUPER_ADMIN' || _role == 'ADMIN_AGENCY';
  bool get isAgent => _role == 'AGENT';
  bool get isClient => _role == 'CLIENT';
  bool get isSuperAdmin => _role == 'SUPER_ADMIN';
  bool get hasAdminNav => isAdmin || isAgent;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await _storage.read(key: 'jwt_token');
      if (_token != null) {
        _role = await _storage.read(key: 'user_role');
        _nom = await _storage.read(key: 'user_nom');
        _prenom = await _storage.read(key: 'user_prenom');
        _email = await _storage.read(key: 'user_email');
        final agenceIdStr = await _storage.read(key: 'user_agence_id');
        _agenceId = agenceIdStr != null ? int.tryParse(agenceIdStr) : null;
        _agenceNom = await _storage.read(key: 'user_agence_nom');
        _agenceLogo = await _storage.read(key: 'user_agence_logo');
        final personneIdStr = await _storage.read(key: 'user_personne_id');
        _personneId = personneIdStr != null ? int.tryParse(personneIdStr) : null;
        _isAuthenticated = true;
      }
    } catch (_) {
      await _clearStorage();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await _apiService.login(email, password);

    _token = data['token'] as String?;
    _role = data['role'] as String?;
    _nom = data['nom'] as String?;
    _prenom = data['prenom'] as String?;
    _email = email;
    _agenceId = data['agenceId'] as int?;
    _agenceNom = data['agenceNom'] as String?;
    _agenceLogo = data['agenceLogo'] as String?;
    _personneId = data['personneId'] as int?;
    _isAuthenticated = true;

    await _storage.write(key: 'jwt_token', value: _token);
    await _storage.write(key: 'user_role', value: _role);
    await _storage.write(key: 'user_nom', value: _nom);
    await _storage.write(key: 'user_prenom', value: _prenom);
    await _storage.write(key: 'user_email', value: email);
    if (_agenceId != null) {
      await _storage.write(key: 'user_agence_id', value: _agenceId.toString());
    }
    if (_agenceNom != null) {
      await _storage.write(key: 'user_agence_nom', value: _agenceNom);
    }
    if (_agenceLogo != null) {
      await _storage.write(key: 'user_agence_logo', value: _agenceLogo);
    }
    if (_personneId != null) {
      await _storage.write(key: 'user_personne_id', value: _personneId.toString());
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _clearStorage();
    _isAuthenticated = false;
    _token = null;
    _role = null;
    _nom = null;
    _prenom = null;
    _email = null;
    _agenceId = null;
    _agenceNom = null;
    _agenceLogo = null;
    _personneId = null;
    notifyListeners();
  }

  Future<void> _clearStorage() async {
    await _storage.deleteAll();
  }
}
