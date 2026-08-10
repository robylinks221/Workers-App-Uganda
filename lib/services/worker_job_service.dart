import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkerJobService {
  Future<Map<String, dynamic>> getJob(int jobId) {
    return _request('GET', ApiConfig.workerJob(jobId));
  }

  Future<Map<String, dynamic>> getApplications() {
    return _request('GET', ApiConfig.workerApplications);
  }

  Future<Map<String, dynamic>> apply({
    required int jobId,
    required String message,
    required double expectedSalary,
  }) {
    return _request('POST', ApiConfig.workerApply(jobId), {
      'message': message.trim(),
      'expected_salary': expectedSalary,
    });
  }

  Future<Map<String, dynamic>> withdrawApplication(int applicationId) {
    return _request(
      'PATCH',
      ApiConfig.workerWithdrawApplication(applicationId),
    );
  }

  Future<Map<String, dynamic>> acceptInvitation(int applicationId) {
    return _request(
      'PATCH',
      ApiConfig.workerAcceptInvitation(applicationId),
    );
  }

  Future<Map<String, dynamic>> declineInvitation(int applicationId) {
    return _request(
      'PATCH',
      ApiConfig.workerDeclineInvitation(applicationId),
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String url, [
    Map<String, dynamic>? body,
  ]) async {
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
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          );
          break;
        default:
          response = await http.get(Uri.parse(url), headers: headers);
      }

      final data = response.body.trim().isEmpty
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
