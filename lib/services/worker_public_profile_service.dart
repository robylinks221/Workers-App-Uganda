import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkerPublicProfileService {
  Future<Map<String, dynamic>> getWorkerProfile(int workerId) {
    return _request(
      method: 'GET',
      url: '${ApiConfig.baseUrl}/workers/$workerId/profile',
    );
  }

  Future<Map<String, dynamic>> saveWorker(int workerId) {
    return _request(
      method: 'POST',
      url: '${ApiConfig.baseUrl}/homeowner/saved-workers/$workerId',
    );
  }

  Future<Map<String, dynamic>> removeSavedWorker(int workerId) {
    return _request(
      method: 'DELETE',
      url: '${ApiConfig.baseUrl}/homeowner/saved-workers/$workerId',
    );
  }

  Future<Map<String, dynamic>> getSavedWorkers() {
    return _request(
      method: 'GET',
      url: '${ApiConfig.baseUrl}/homeowner/saved-workers',
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String url,
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
      };

      late http.Response response;

      switch (method) {
        case 'POST':
          response = await http.post(Uri.parse(url), headers: headers);
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        default:
          response = await http.get(Uri.parse(url), headers: headers);
      }

      final data = _decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      return {
        'success': false,
        'message': data['message'] ?? 'The request could not be completed.',
        'errors': data['errors'],
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

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return <String, dynamic>{};
  }
}
