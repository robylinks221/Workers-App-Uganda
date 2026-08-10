import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkerMarketplaceService {
  Future<Map<String, dynamic>> getWorkers({
    String search = '',
    String district = '',
    String gender = '',
    String religion = '',
    String workType = '',
    String availability = '',
    String service = '',
    int? minAge,
    int? maxAge,
    double? rating,
    bool? featured,
    String sort = 'newest',
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'sort': sort,
    };

    void add(String key, String value) {
      if (value.trim().isNotEmpty) {
        query[key] = value.trim();
      }
    }

    add('search', search);
    add('district', district);
    add('gender', gender);
    add('religion', religion);
    add('work_type', workType);
    add('availability', availability);
    add('service', service);

    if (minAge != null) {
      query['min_age'] = minAge.toString();
    }

    if (maxAge != null) {
      query['max_age'] = maxAge.toString();
    }

    if (rating != null) {
      query['rating'] = rating.toString();
    }

    if (featured != null) {
      query['featured'] = featured ? '1' : '0';
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/workers',
    ).replace(queryParameters: query);

    return _request('GET', uri);
  }

  Future<Map<String, dynamic>> getCategories() {
    return _request(
      'GET',
      Uri.parse('${ApiConfig.baseUrl}/service-categories'),
    );
  }

  Future<Map<String, dynamic>> saveWorker(int workerId) {
    return _request(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/homeowner/saved-workers/$workerId'),
    );
  }

  Future<Map<String, dynamic>> removeSavedWorker(int workerId) {
    return _request(
      'DELETE',
      Uri.parse('${ApiConfig.baseUrl}/homeowner/saved-workers/$workerId'),
    );
  }

  Future<Map<String, dynamic>> _request(String method, Uri uri) async {
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
          response = await http.post(uri, headers: headers);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      final data = _decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      return {
        'success': false,
        'message':
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
}
