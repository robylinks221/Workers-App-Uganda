import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.login(
      phone: phone,
      password: password,
    );

    _user = result.user;
    _errorMessage = result.success ? null : result.message;
    _setLoading(false);

    return result.success;
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String location,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.register(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
      location: location,
    );

    _user = result.user;
    _errorMessage = result.success ? null : result.message;
    _setLoading(false);

    return result.success;
  }

  Future<void> loadCurrentUser() async {
    _user = await _authService.currentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
