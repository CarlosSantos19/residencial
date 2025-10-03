import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Provider de autenticación para gestionar el estado del usuario
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;

  /// Establecer usuario y token después del login
  void setUser(User user, String token) {
    _currentUser = user;
    _token = token;
    notifyListeners();
  }

  /// Cerrar sesión
  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  /// Actualizar datos del usuario
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
