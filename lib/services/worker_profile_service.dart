import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class WorkerProfileService {
  Future<Map<String, dynamic>> saveProfile({
    required String fullName,
    required int age,
    required String religion,
    required String gender,
    required String district,
    required String workType,
    List<int>? serviceIds,
    List<String>? languages,
    String availability = 'available',
    String? bio,
    int experienceYears = 0,
    double? hourlyRate,
    double? monthlyRate,
    XFile? profilePhoto,
    XFile? nationalIdFrontDocument,
    XFile? nationalIdBackDocument,
    XFile? galleryImage1,
    XFile? galleryImage2,
    XFile? galleryImage3,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
      };
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.workerProfile),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'full_name': fullName.trim(),
        'age': age.toString(),
        'religion': religion,
        'gender': gender,
        'district': district.trim(),
        'work_type': workType,
        'availability': availability,
        'experience_years': experienceYears.toString(),
      });

      if (serviceIds != null) {
        for (var index = 0; index < serviceIds.length; index++) {
          request.fields['service_ids[$index]'] = serviceIds[index].toString();
        }
      }

      if (languages != null) {
        for (var index = 0; index < languages.length; index++) {
          request.fields['languages[$index]'] = languages[index];
        }
      }

      if (bio != null && bio.trim().isNotEmpty) {
        request.fields['bio'] = bio.trim();
      }

      if (hourlyRate != null) {
        request.fields['hourly_rate'] = hourlyRate.toString();
      }

      if (monthlyRate != null) {
        request.fields['monthly_rate'] = monthlyRate.toString();
      }

      if (profilePhoto != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_photo',
            await profilePhoto.readAsBytes(),
            filename: profilePhoto.name,
          ),
        );
      }

      if (nationalIdFrontDocument != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'national_id_front_document',
            await nationalIdFrontDocument.readAsBytes(),
            filename: nationalIdFrontDocument.name,
          ),
        );
      }

      if (nationalIdBackDocument != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'national_id_back_document',
            await nationalIdBackDocument.readAsBytes(),
            filename: nationalIdBackDocument.name,
          ),
        );
      }

      final galleryFiles = <XFile?>[
        galleryImage1,
        galleryImage2,
        galleryImage3,
      ];

      for (var index = 0; index < galleryFiles.length; index++) {
        final image = galleryFiles[index];

        if (image == null) {
          continue;
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'gallery_image_${index + 1}',
            await image.readAsBytes(),
            filename: image.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decodeResponse(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Worker profile saved successfully.',
          'profile': data['profile'],
          'user': data['user'],
        };
      }

      if (response.statusCode == 401) {
        await TokenStorage.removeToken();

        return {
          'success': false,
          'message': 'Your session has expired. Please log in again.',
        };
      }

      return {
        'success': false,
        'message':
            _firstValidationMessage(data) ??
            data['message'] ??
            'Unable to save the worker profile.',
        'errors': data['errors'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
      };
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.workerProfile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'profile': data['profile'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Unable to load the worker profile.',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }

  Future<Map<String, dynamic>> resubmitVerification() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
      };
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.workerVerificationResubmit),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message'] ?? 'Unable to resubmit verification.',
        'profile': data['profile'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);

    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  String? _firstValidationMessage(Map<String, dynamic> data) {
    final errors = data['errors'];

    if (errors is! Map || errors.isEmpty) {
      return null;
    }

    final first = errors.values.first;

    if (first is List && first.isNotEmpty) {
      return first.first.toString();
    }

    return first.toString();
  }
}
