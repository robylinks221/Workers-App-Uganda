import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    await registerCurrentDevice();

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed.');
      await _sendTokenToLaravel(newToken);
    });
  }

  Future<bool> registerCurrentDevice() async {
    try {
      final authToken = await TokenStorage.getToken();

      if (authToken == null || authToken.isEmpty) {
        debugPrint(
          'FCM registration postponed: user is not authenticated yet.',
        );
        return false;
      }

      final fcmToken = await _messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('FCM registration failed: no Firebase token received.');
        return false;
      }

      return await _sendTokenToLaravel(fcmToken);
    } catch (error) {
      debugPrint('FCM device registration error: $error');
      return false;
    }
  }

  Future<bool> _sendTokenToLaravel(String fcmToken) async {
    try {
      final authToken = await TokenStorage.getToken();

      if (authToken == null || authToken.isEmpty) {
        debugPrint(
          'FCM token not sent: Laravel authentication is unavailable.',
        );
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.deviceTokens),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': fcmToken, 'platform': 'android'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('FCM device registered with Laravel successfully.');
        return true;
      }

      debugPrint(
        'FCM Laravel registration failed '
        '(${response.statusCode}): ${response.body}',
      );
      return false;
    } catch (error) {
      debugPrint('FCM Laravel registration error: $error');
      return false;
    }
  }

  Future<void> unregisterCurrentDevice() async {
    try {
      final authToken = await TokenStorage.getToken();
      final fcmToken = await _messaging.getToken();

      if (authToken == null ||
          authToken.isEmpty ||
          fcmToken == null ||
          fcmToken.isEmpty) {
        return;
      }

      final request = http.Request('DELETE', Uri.parse(ApiConfig.deviceTokens));

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      request.body = jsonEncode({'token': fcmToken});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint('FCM device removed from Laravel successfully.');
      } else {
        debugPrint(
          'FCM device removal failed '
          '(${response.statusCode}): ${response.body}',
        );
      }
    } catch (error) {
      debugPrint('FCM device removal error: $error');
    }
  }
}
