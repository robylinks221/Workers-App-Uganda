import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class AdminService {
  Future<Map<String, dynamic>> dashboard() => _get(ApiConfig.adminDashboard);

  Future<Map<String, dynamic>> verifications({String status = 'pending'}) {
    return _get('${ApiConfig.adminWorkerVerifications}?status=$status');
  }

  Future<Map<String, dynamic>> users({
    String? role,
    String? status,
    String? search,
  }) {
    final query = <String, String>{};
    if (role != null && role.isNotEmpty) query['role'] = role;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.trim().isNotEmpty)
      query['search'] = search.trim();
    final uri = Uri.parse(
      ApiConfig.adminUsers,
    ).replace(queryParameters: query.isEmpty ? null : query);
    return _get(uri.toString());
  }

  Future<Map<String, dynamic>> user(int userId) =>
      _get(ApiConfig.adminUser(userId));
  Future<Map<String, dynamic>> suspendUser(int userId, String reason) =>
      _post(ApiConfig.adminSuspendUser(userId), body: {'reason': reason});
  Future<Map<String, dynamic>> activateUser(int userId) =>
      _post(ApiConfig.adminActivateUser(userId));
  Future<Map<String, dynamic>> deactivateUser(int userId, String reason) =>
      _post(ApiConfig.adminDeactivateUser(userId), body: {'reason': reason});

  Future<Map<String, dynamic>> accountAppeals({String status = 'pending'}) =>
      _get('${ApiConfig.adminAccountAppeals}?status=$status');

  Future<Map<String, dynamic>> approveAppeal(
    int appealId, {
    String? response,
  }) => _post(
    ApiConfig.adminApproveAppeal(appealId),
    body: {'response': response},
  );

  Future<Map<String, dynamic>> rejectAppeal(int appealId, String response) =>
      _post(
        ApiConfig.adminRejectAppeal(appealId),
        body: {'response': response},
      );

  Future<Map<String, dynamic>> verification(int profileId) {
    return _get(ApiConfig.adminWorkerVerification(profileId));
  }

  Future<Map<String, dynamic>> approve(int profileId) {
    return _post(ApiConfig.adminApproveWorker(profileId));
  }

  Future<Map<String, dynamic>> reject(int profileId, String reason) {
    return _post(
      ApiConfig.adminRejectWorker(profileId),
      body: {'reason': reason.trim()},
    );
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Admin session expired.'};
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return _response(response);
    } catch (error) {
      return {
        'success': false,
        'message': 'Could not connect to Laravel. $error',
      };
    }
  }

  Future<Map<String, dynamic>> _post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Admin session expired.'};
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body ?? const <String, dynamic>{}),
      );
      return _response(response);
    } catch (error) {
      return {
        'success': false,
        'message': 'Could not connect to Laravel. $error',
      };
    }
  }

  Map<String, dynamic> _response(http.Response response) {
    Map<String, dynamic> data = <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {...data, 'success': data['success'] ?? true};
    }

    return {
      ...data,
      'success': false,
      'message': data['message'] ?? 'Request failed (${response.statusCode}).',
    };
  }
}
