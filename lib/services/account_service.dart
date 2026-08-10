import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class AccountService {
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) {
    return _request(
      method: 'PUT',
      url: '${ApiConfig.baseUrl}/account/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmation,
      },
    );
  }

  Future<Map<String, dynamic>> logoutOtherDevices({required String password}) {
    return _request(
      method: 'POST',
      url: '${ApiConfig.baseUrl}/account/logout-other-devices',
      body: {'password': password},
    );
  }

  Future<Map<String, dynamic>> logoutAllDevices({required String password}) {
    return _request(
      method: 'POST',
      url: '${ApiConfig.baseUrl}/account/logout-all-devices',
      body: {'password': password},
    );
  }

  Future<Map<String, dynamic>> deactivateAccount({required String password}) {
    return _request(
      method: 'POST',
      url: ApiConfig.accountDeactivate,
      body: {'password': password},
    );
  }

  Future<Map<String, dynamic>> requestAccountDeletion({
    required String password,
  }) {
    return _request(
      method: 'POST',
      url: ApiConfig.accountRequestDeletion,
      body: {'password': password, 'confirmation': 'DELETE'},
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String url,
    required Map<String, dynamic> body,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
      };
    }

    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      late http.Response response;

      if (method == 'PUT') {
        response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
      }

      final data =
          response.body.trim().isEmpty
              ? <String, dynamic>{}
              : Map<String, dynamic>.from(jsonDecode(response.body) as Map);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Request failed.',
        'errors': data['errors'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'We could not connect. Please try again.',
      };
    }
  }
}
