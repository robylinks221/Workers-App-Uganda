import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkerHomeService {
  Future<Map<String, dynamic>> getHome() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
        'unauthenticated': true,
      };
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.workerHome),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      if (response.statusCode == 401) {
        await TokenStorage.removeToken();

        return {
          'success': false,
          'message': 'Your session has expired. Please log in again.',
          'unauthenticated': true,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Unable to load worker home.',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }
}
