import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class GuestMarketplaceService {
  Future<Map<String, dynamic>> getWorkers({
    String search = '',
    String service = '',
    int page = 1,
    int perPage = 20,
  }) async {
    final uri = Uri.parse(ApiConfig.guestWorkers).replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (service.trim().isNotEmpty) 'service': service.trim(),
      },
    );
    return _get(uri);
  }

  Future<Map<String, dynamic>> getCategories() =>
      _get(Uri.parse(ApiConfig.guestServiceCategories));

  Future<Map<String, dynamic>> getWorker(int workerId) =>
      _get(Uri.parse(ApiConfig.guestWorkerProfile(workerId)));

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
      final data = _decode(response.body);
      return {
        ...data,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            (data['success'] ?? true) == true,
        if (data['message'] == null && response.statusCode >= 400)
          'message': 'Request failed (${response.statusCode}).',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $e',
      };
    }
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }
}
