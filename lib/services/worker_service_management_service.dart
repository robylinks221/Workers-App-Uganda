import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkerServiceManagementService {
  Future<Map<String, dynamic>> getCategories() {
    return _request(
      method: 'GET',
      url: '${ApiConfig.baseUrl}/service-categories',
    );
  }

  Future<Map<String, dynamic>> getSelectedServices() {
    return _request(method: 'GET', url: '${ApiConfig.baseUrl}/worker/services');
  }

  Future<Map<String, dynamic>> updateServices(List<int> serviceIds) {
    return _request(
      method: 'PUT',
      url: '${ApiConfig.baseUrl}/worker/services',
      body: {'service_ids': serviceIds},
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
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

      switch (method) {
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          );
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
        'message':
            _firstError(data) ??
            data['message']?.toString() ??
            'The request could not be completed.',
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

  String? _firstError(Map<String, dynamic> data) {
    final errors = data['errors'];

    if (errors is! Map || errors.isEmpty) {
      return null;
    }

    final firstValue = errors.values.first;

    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }

    return firstValue.toString();
  }
}
