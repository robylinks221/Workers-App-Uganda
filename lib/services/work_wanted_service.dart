import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkWantedService {
  Future<Map<String, dynamic>> mine() => _get(ApiConfig.workerWorkWanted);
  Future<Map<String, dynamic>> browse() => _get(ApiConfig.homeownerWorkWanted);

  Future<Map<String, dynamic>> categories() =>
      _get(ApiConfig.serviceCategories);

  Future<Map<String, dynamic>> save({
    int? id,
    required Map<String, dynamic> data,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return _expired;
    final uri = Uri.parse(
      id == null ? ApiConfig.workerWorkWanted : ApiConfig.workWantedPost(id),
    );
    final response =
        id == null
            ? await http.post(
              uri,
              headers: _headers(token),
              body: jsonEncode(data),
            )
            : await http.put(
              uri,
              headers: _headers(token),
              body: jsonEncode(data),
            );
    return _result(response);
  }

  Future<Map<String, dynamic>> setStatus(int id, String status) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return _expired;
    final response = await http.patch(
      Uri.parse(ApiConfig.workWantedStatus(id)),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    return _result(response);
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return _expired;
    try {
      return _result(await http.get(Uri.parse(url), headers: _headers(token)));
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $e',
      };
    }
  }

  Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _result(http.Response response) {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) data = Map<String, dynamic>.from(decoded);
    } catch (_) {}
    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    final errors = data['errors'];
    String? first;
    if (errors is Map && errors.isNotEmpty) {
      final value = errors.values.first;
      first =
          value is List && value.isNotEmpty
              ? value.first.toString()
              : value.toString();
    }
    return {
      'success': false,
      ...data,
      'message': first ?? data['message'] ?? 'Request failed.',
    };
  }

  Map<String, dynamic> get _expired => {
    'success': false,
    'message': 'Your session has expired. Please log in again.',
  };
}
