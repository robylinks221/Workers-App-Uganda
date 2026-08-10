import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class HomeownerProfileService {
  Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
        'unauthenticated': true,
      };
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.homeownerProfile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      if (response.statusCode == 401) {
        await TokenStorage.removeToken();

        return {
          'success': false,
          'message': 'Your session has expired. Please log in again.',
          'unauthenticated': true,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Unable to load homeowner profile.',
        'errors': data['errors'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }

  Future<Map<String, dynamic>> saveProfile({
    required String fullName,
    required String email,
    required String address,
    required String city,
    required String district,
    required String country,
    required String preferredContact,
    XFile? profilePhoto,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Your session has expired. Please log in again.',
        'unauthenticated': true,
      };
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.homeownerProfile),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'full_name': fullName.trim(),
        'email': email.trim(),
        'address': address.trim(),
        'city': city.trim(),
        'district': district.trim(),
        'country': country.trim().isEmpty ? 'Uganda' : country.trim(),
        'preferred_contact': preferredContact,
      });

      if (profilePhoto != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_photo',
            await profilePhoto.readAsBytes(),
            filename: profilePhoto.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      if (response.statusCode == 401) {
        await TokenStorage.removeToken();

        return {
          'success': false,
          'message': 'Your session has expired. Please log in again.',
          'unauthenticated': true,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Unable to save homeowner profile.',
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

    return <String, dynamic>{};
  }
}
