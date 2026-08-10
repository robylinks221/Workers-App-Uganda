import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class IdentityAccessService {
  Future<Map<String, dynamic>> status(int workerId) {
    return _request('GET', ApiConfig.workerIdentityAccessStatus(workerId));
  }

  Future<Map<String, dynamic>> requestAccess(int workerId) {
    return _request('POST', ApiConfig.requestWorkerIdentityAccess(workerId));
  }

  Future<Map<String, dynamic>> _request(String method, String url) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Please sign in as a homeowner to continue.',
      };
    }

    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response =
          method == 'POST'
              ? await http.post(Uri.parse(url), headers: headers)
              : await http.get(Uri.parse(url), headers: headers);

      final decoded =
          response.body.trim().isEmpty
              ? <String, dynamic>{}
              : jsonDecode(response.body);

      final data =
          decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      return {
        'success': false,
        'message':
            data['message']?.toString() ?? 'Unable to complete this request.',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'We could not connect. Please try again.',
      };
    }
  }
}
