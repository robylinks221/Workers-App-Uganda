import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ProfileSectionService {
  Future<Map<String, dynamic>> updateWorkerPersonal({
    required String fullName,
    required int age,
    required String religion,
    required String gender,
    required String district,
    XFile? profilePhoto,
  }) {
    return _multipart(
      url: '${ApiConfig.baseUrl}/worker/profile/personal',
      fields: {
        'full_name': fullName.trim(),
        'age': age.toString(),
        'religion': religion,
        'gender': gender,
        'district': district.trim(),
      },
      files: {'profile_photo': profilePhoto},
    );
  }

  Future<Map<String, dynamic>> updateHomeownerPersonal({
    required String fullName,
    required String email,
    XFile? profilePhoto,
  }) {
    return _multipart(
      url: '${ApiConfig.baseUrl}/homeowner/profile/personal',
      fields: {'full_name': fullName.trim(), 'email': email.trim()},
      files: {'profile_photo': profilePhoto},
    );
  }

  Future<Map<String, dynamic>> _multipart({
    required String url,
    required Map<String, String> fields,
    required Map<String, XFile?> files,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
      };
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll(fields);

      for (final entry in files.entries) {
        final file = entry.value;

        if (file == null) {
          continue;
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            entry.key,
            await file.readAsBytes(),
            filename: file.name,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = _decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      return {
        'success': false,
        'message':
            _firstError(data) ?? data['message'] ?? 'Unable to update profile.',
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

    final first = errors.values.first;

    if (first is List && first.isNotEmpty) {
      return first.first.toString();
    }

    return first.toString();
  }
}
