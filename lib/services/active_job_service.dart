import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ActiveJobService {
  Future<Map<String, dynamic>> getWorkerJob(int jobId) {
    return _request('GET', ApiConfig.workerActiveJob(jobId));
  }

  Future<Map<String, dynamic>> startJob(int jobId) {
    return _request('PATCH', ApiConfig.workerStartJob(jobId));
  }

  Future<Map<String, dynamic>> markWorkFinished(int jobId) {
    return _request('PATCH', ApiConfig.workerCompleteJob(jobId));
  }

  Future<Map<String, dynamic>> withdrawFromJob({
    required int jobId,
    required String reason,
    String note = '',
  }) {
    return _request(
      'PATCH',
      ApiConfig.workerWithdrawActiveJob(jobId),
      body: {'reason': reason, if (note.trim().isNotEmpty) 'note': note.trim()},
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String url, {
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

      final response =
          method == 'PATCH'
              ? await http.patch(
                Uri.parse(url),
                headers: headers,
                body: jsonEncode(body ?? <String, dynamic>{}),
              )
              : await http.get(Uri.parse(url), headers: headers);

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
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $e',
      };
    }
  }
}
