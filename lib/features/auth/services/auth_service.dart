import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../storage/token_storage.dart';
import '../../../services/firebase_messaging_service.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.errors,
    this.reactivated = false,
    this.restoredDeletion = false,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? errors;
  final bool reactivated;
  final bool restoredDeletion;
}

class AuthService {
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone.trim(), 'password': password}),
      );

      final data = _decodeResponse(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token']?.toString();
        final user = data['user'];

        if (token == null || token.isEmpty || user is! Map) {
          return const AuthResult(
            success: false,
            message: 'The server returned incomplete login information.',
          );
        }

        await TokenStorage.saveToken(token);
        await FirebaseMessagingService.instance.registerCurrentDevice();

        return AuthResult(
          success: true,
          message: data['message']?.toString() ?? 'Login successful.',
          user: Map<String, dynamic>.from(user),
          reactivated: data['reactivated'] == true,
          restoredDeletion: data['restored_deletion'] == true,
        );
      }

      return AuthResult(
        success: false,
        message: _errorMessage(data, 'Incorrect phone number or password.'),
        errors: _errors(data),
      );
    } catch (error) {
      debugPrint('Login error: $error');
      return const AuthResult(
        success: false,
        message:
            'Could not connect to the server. Confirm that Laravel is running.',
      );
    }
  }

  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
          'location': location.trim(),
        }),
      );

      final data = _decodeResponse(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final token = data['token']?.toString();
        final user = data['user'];

        if (token == null || token.isEmpty || user is! Map) {
          return const AuthResult(
            success: false,
            message: 'The server returned incomplete registration information.',
          );
        }

        await TokenStorage.saveToken(token);
        await FirebaseMessagingService.instance.registerCurrentDevice();

        return AuthResult(
          success: true,
          message: data['message']?.toString() ?? 'Registration successful.',
          user: Map<String, dynamic>.from(user),
        );
      }

      return AuthResult(
        success: false,
        message: _errorMessage(
          data,
          'Registration failed. Please check your details.',
        ),
        errors: _errors(data),
      );
    } catch (error) {
      debugPrint('Registration error: $error');
      return const AuthResult(
        success: false,
        message:
            'Could not connect to the server. Confirm that Laravel is running.',
      );
    }
  }

  Future<Map<String, dynamic>?> currentUser() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.me),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await TokenStorage.removeToken();
        return null;
      }

      if (response.statusCode != 200) {
        return null;
      }

      final data = _decodeResponse(response.body);
      final user = data['user'];
      if (user is Map) {
        await FirebaseMessagingService.instance.registerCurrentDevice();
        return Map<String, dynamic>.from(user);
      }
      return null;
    } catch (error) {
      debugPrint('Current-user error: $error');
      return null;
    }
  }

  Future<AuthResult> logout() async {
    final token = await TokenStorage.getToken();

    try {
      if (token != null && token.isNotEmpty) {
        await FirebaseMessagingService.instance.unregisterCurrentDevice();

        final response = await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        final data = _decodeResponse(response.body);
        await TokenStorage.removeToken();

        return AuthResult(
          success: response.statusCode == 200,
          message: data['message']?.toString() ?? 'Logged out successfully.',
        );
      }

      await TokenStorage.removeToken();
      return const AuthResult(success: true, message: 'Already logged out.');
    } catch (error) {
      debugPrint('Logout error: $error');
      await TokenStorage.removeToken();

      return const AuthResult(
        success: false,
        message: 'Logged out locally, but the server could not be reached.',
      );
    }
  }

  Future<String?> getToken() => TokenStorage.getToken();

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic>? _errors(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map) return null;
    return Map<String, dynamic>.from(errors);
  }

  String _errorMessage(Map<String, dynamic> data, String fallback) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value != null) {
          return value.toString();
        }
      }
    }

    return fallback;
  }
}
