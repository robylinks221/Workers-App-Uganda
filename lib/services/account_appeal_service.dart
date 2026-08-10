import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class AccountAppealService {
  Future<Map<String, dynamic>> status() => _get(ApiConfig.accountStatus);

  Future<Map<String, dynamic>> submit(String message) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Your session has expired.'};
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.accountAppeals),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': message.trim()}),
      );
      return _response(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Could not connect to the server. $e',
      };
    }
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Your session has expired.'};
    }
    try {
      return _response(
        await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Could not connect to the server. $e',
      };
    }
  }

  Map<String, dynamic> _response(http.Response response) {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    return {
      ...data,
      'success':
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          (data['success'] ?? true) == true,
      if (data['message'] == null)
        'message': 'Request failed (${response.statusCode}).',
    };
  }
}
