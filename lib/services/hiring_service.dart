import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class HiringService {
  Future<Map<String, dynamic>> getAvailableJobs() {
    return _request(method: 'GET', url: ApiConfig.hiringAvailableJobs);
  }

  Future<Map<String, dynamic>> getWorkerHiringRequests() {
    return _request(method: 'GET', url: ApiConfig.workerHiringRequests);
  }

  Future<Map<String, dynamic>> getHiringRequest(int requestId) {
    return _request(method: 'GET', url: ApiConfig.hiringRequest(requestId));
  }

  Future<Map<String, dynamic>> acceptHiringRequest(int requestId) {
    return _request(
      method: 'POST',
      url: ApiConfig.acceptHiringRequest(requestId),
    );
  }

  Future<Map<String, dynamic>> declineHiringRequest(int requestId) {
    return _request(
      method: 'POST',
      url: ApiConfig.declineHiringRequest(requestId),
    );
  }

  Future<Map<String, dynamic>> getHomeownerHiringRequests() {
    return _request(method: 'GET', url: ApiConfig.homeownerHiringRequests);
  }

  Future<Map<String, dynamic>> cancelHiringRequest(int requestId) {
    return _request(
      method: 'POST',
      url: ApiConfig.cancelHiringRequest(requestId),
    );
  }

  Future<Map<String, dynamic>> completeHiringRequest(int requestId) {
    return _request(
      method: 'POST',
      url: ApiConfig.completeHiringRequest(requestId),
    );
  }

  Future<Map<String, dynamic>> sendHiringRequest({
    required int jobId,
    required int workerId,
    required double offeredAmount,
    required String message,
    String? startDate,
  }) {
    return _request(
      method: 'POST',
      url: ApiConfig.hiringRequests,
      body: {
        'job_id': jobId,
        'worker_id': workerId,
        'offered_amount': offeredAmount,
        if (message.trim().isNotEmpty) 'message': message.trim(),
        if (startDate != null && startDate.trim().isNotEmpty)
          'start_date': startDate.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> sendQuickHiringRequest({required int workerId}) {
    return _request(
      method: 'POST',
      url: ApiConfig.quickHiringRequests,
      body: {'worker_id': workerId},
    );
  }

  Future<Map<String, dynamic>> sendDirectOffer({
    required int workerId,
    required String title,
    required String description,
    required String address,
    required String district,
    required String startDate,
    required String duration,
    required String budgetType,
    required double offeredAmount,
    required List<int> serviceIds,
    String? workArrangement,
    String? message,
  }) {
    return _request(
      method: 'POST',
      url: ApiConfig.directHiringOffers,
      body: {
        'worker_id': workerId,
        'title': title.trim(),
        'description': description.trim(),
        'address': address.trim(),
        'district': district.trim(),
        'start_date': startDate,
        'duration': duration.trim(),
        'budget_type': budgetType,
        'offered_amount': offeredAmount,
        'service_ids': serviceIds,
        if (workArrangement != null && workArrangement.trim().isNotEmpty)
          'work_arrangement': workArrangement.trim(),
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
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

      final response =
          method == 'POST'
              ? await http.post(
                Uri.parse(url),
                headers: headers,
                body: jsonEncode(body ?? <String, dynamic>{}),
              )
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
            _firstError(data) ??
            data['message']?.toString() ??
            'Request failed.',
        'errors': data['errors'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }

  String? _firstError(Map<String, dynamic> data) {
    final errors = data['errors'];

    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }

    return null;
  }
}
