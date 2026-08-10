import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class SavedWorkersService {
  Future<Map<String, dynamic>> getSavedWorkers() {
    return _request(
      method: 'GET',
      url: '${ApiConfig.baseUrl}/homeowner/saved-workers',
    );
  }

  Future<Map<String, dynamic>> removeWorker(int workerId) {
    return _request(
      method: 'DELETE',
      url: '${ApiConfig.baseUrl}/homeowner/saved-workers/$workerId',
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

      if (method == 'DELETE') {
        response = await http.delete(Uri.parse(url), headers: headers);
      } else {
        response = await http.get(Uri.parse(url), headers: headers);
      }

      final data =
          response.body.trim().isEmpty
              ? <String, dynamic>{}
              : Map<String, dynamic>.from(jsonDecode(response.body));

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
        'message': 'Unable to connect to the server. $error',
      };
    }
  }
}
