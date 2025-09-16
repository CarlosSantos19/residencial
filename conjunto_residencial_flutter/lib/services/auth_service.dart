import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _token != null;

  // Inicializar y verificar token guardado
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');

      if (savedToken != null) {
        _token = savedToken;
        _apiService.setToken(savedToken);

        final response = await _apiService.verifyToken();
        if (response.success && response.usuario != null) {
          _currentUser = response.usuario;
          _clearError();
        } else {
          await logout();
        }
      }
    } catch (e) {
      _setError('Error inicializando autenticación: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(email, password);

      if (response.success && response.token != null && response.usuario != null) {
        _token = response.token;
        _currentUser = response.usuario;
        _apiService.setToken(_token!);

        // Guardar token en storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError(response.mensaje ?? 'Error en el login');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register(
    String nombre,
    String email,
    String apartamento,
    String password,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.register(nombre, email, apartamento, password);

      if (response.success) {
        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError(response.mensaje ?? 'Error en el registro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      _currentUser = null;
      _token = null;
      _clearError();

      notifyListeners();
    } catch (e) {
      _setError('Error cerrando sesión: $e');
    }
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar error manualmente
  void clearError() {
    _clearError();
  }
}