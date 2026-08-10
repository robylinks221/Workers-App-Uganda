import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class HomeownerJobService {
  Future<Map<String, dynamic>> getServiceCategories() {
    return _request(method: 'GET', url: ApiConfig.serviceCategories);
  }

  Future<Map<String, dynamic>> getJobs() {
    return _request(method: 'GET', url: ApiConfig.homeownerJobs);
  }

  Future<Map<String, dynamic>> getJob(int jobId) {
    return _request(method: 'GET', url: ApiConfig.homeownerJob(jobId));
  }

  Future<Map<String, dynamic>> createJob({
    required String title,
    required List<int> serviceCategoryIds,
    required String description,
    required String address,
    required String district,
    required String startDate,
    required String startTime,
    required String workArrangement,
    required String contractDuration,
    required String budgetType,
    required double budgetAmount,
    required bool accommodationProvided,
    required bool mealsProvided,
    required bool transportAllowance,
    required bool medicalSupport,
    required bool uniformProvided,
    required String otherBenefits,
    required bool isUrgent,
  }) {
    return _saveJob(
      method: 'POST',
      url: ApiConfig.homeownerJobs,
      title: title,
      serviceCategoryIds: serviceCategoryIds,
      description: description,
      address: address,
      district: district,
      startDate: startDate,
      startTime: startTime,
      workArrangement: workArrangement,
      contractDuration: contractDuration,
      budgetType: budgetType,
      budgetAmount: budgetAmount,
      accommodationProvided: accommodationProvided,
      mealsProvided: mealsProvided,
      transportAllowance: transportAllowance,
      medicalSupport: medicalSupport,
      uniformProvided: uniformProvided,
      otherBenefits: otherBenefits,
      isUrgent: isUrgent,
    );
  }

  Future<Map<String, dynamic>> updateJob({
    required int jobId,
    required String title,
    required List<int> serviceCategoryIds,
    required String description,
    required String address,
    required String district,
    required String startDate,
    required String startTime,
    required String workArrangement,
    required String contractDuration,
    required String budgetType,
    required double budgetAmount,
    required bool accommodationProvided,
    required bool mealsProvided,
    required bool transportAllowance,
    required bool medicalSupport,
    required bool uniformProvided,
    required String otherBenefits,
    required bool isUrgent,
  }) {
    return _saveJob(
      method: 'PUT',
      url: ApiConfig.homeownerJob(jobId),
      title: title,
      serviceCategoryIds: serviceCategoryIds,
      description: description,
      address: address,
      district: district,
      startDate: startDate,
      startTime: startTime,
      workArrangement: workArrangement,
      contractDuration: contractDuration,
      budgetType: budgetType,
      budgetAmount: budgetAmount,
      accommodationProvided: accommodationProvided,
      mealsProvided: mealsProvided,
      transportAllowance: transportAllowance,
      medicalSupport: medicalSupport,
      uniformProvided: uniformProvided,
      otherBenefits: otherBenefits,
      isUrgent: isUrgent,
    );
  }

  Future<Map<String, dynamic>> _saveJob({
    required String method,
    required String url,
    required String title,
    required List<int> serviceCategoryIds,
    required String description,
    required String address,
    required String district,
    required String startDate,
    required String startTime,
    required String workArrangement,
    required String contractDuration,
    required String budgetType,
    required double budgetAmount,
    required bool accommodationProvided,
    required bool mealsProvided,
    required bool transportAllowance,
    required bool medicalSupport,
    required bool uniformProvided,
    required String otherBenefits,
    required bool isUrgent,
  }) {
    return _request(
      method: method,
      url: url,
      body: {
        'title': title.trim(),
        'service_category_ids': serviceCategoryIds,
        'description': description.trim(),
        'address': address.trim(),
        'district': district.trim(),
        'start_date': startDate,
        if (startTime.trim().isNotEmpty) 'start_time': startTime.trim(),
        'work_arrangement': workArrangement,
        'contract_duration': contractDuration,
        'budget_type': budgetType,
        'budget_amount': budgetAmount,
        'accommodation_provided': accommodationProvided,
        'meals_provided': mealsProvided,
        'transport_allowance': transportAllowance,
        'medical_support': medicalSupport,
        'uniform_provided': uniformProvided,
        if (otherBenefits.trim().isNotEmpty)
          'other_benefits': otherBenefits.trim(),
        'is_urgent': isUrgent,
      },
    );
  }

  Future<Map<String, dynamic>> deleteJob(int jobId) {
    return _request(method: 'DELETE', url: ApiConfig.homeownerJob(jobId));
  }

  Future<Map<String, dynamic>> inviteWorker({
    required int jobId,
    required int workerId,
    String message = '',
  }) {
    return _request(
      method: 'POST',
      url: ApiConfig.homeownerInviteWorker(jobId),
      body: {
        'worker_id': workerId,
        if (message.trim().isNotEmpty) 'message': message.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> getApplications(int jobId) {
    return _request(
      method: 'GET',
      url: ApiConfig.homeownerJobApplications(jobId),
    );
  }

  Future<Map<String, dynamic>> acceptApplication(int applicationId) {
    return _request(
      method: 'PATCH',
      url: ApiConfig.homeownerAcceptApplication(applicationId),
    );
  }

  Future<Map<String, dynamic>> declineApplication(int applicationId) {
    return _request(
      method: 'PATCH',
      url: ApiConfig.homeownerDeclineApplication(applicationId),
    );
  }

  Future<Map<String, dynamic>> confirmCompletion(int jobId) {
    return _request(
      method: 'PATCH',
      url: ApiConfig.homeownerConfirmCompletion(jobId),
    );
  }

  Future<Map<String, dynamic>> cancelActiveJob({
    required int jobId,
    required String reason,
    String note = '',
  }) {
    return _request(
      method: 'PATCH',
      url: ApiConfig.homeownerCancelActiveJob(jobId),
      body: {'reason': reason, if (note.trim().isNotEmpty) 'note': note.trim()},
    );
  }

  Future<Map<String, dynamic>> getReview(int jobId) {
    return _request(method: 'GET', url: ApiConfig.homeownerReviewJob(jobId));
  }

  Future<Map<String, dynamic>> createReview({
    required int jobId,
    required int rating,
    required String comment,
  }) {
    return _request(
      method: 'POST',
      url: ApiConfig.homeownerReviewJob(jobId),
      body: {'rating': rating, 'comment': comment.trim()},
    );
  }

  Future<Map<String, dynamic>> updateReview({
    required int jobId,
    required int rating,
    required String comment,
  }) {
    return _request(
      method: 'PUT',
      url: ApiConfig.homeownerReviewJob(jobId),
      body: {'rating': rating, 'comment': comment.trim()},
    );
  }

  Future<Map<String, dynamic>> deleteReview(int jobId) {
    return _request(method: 'DELETE', url: ApiConfig.homeownerReviewJob(jobId));
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
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body ?? <String, dynamic>{}),
          );
          break;
        case 'PUT':
          response = await http.put(
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
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
        default:
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
