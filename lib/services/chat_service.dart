import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat_models.dart';
import '../storage/token_storage.dart';

class ChatService {
  Future<List<ChatConversation>> getConversations() async {
    final result = await _request('GET', ApiConfig.conversations);

    if (result['success'] != true) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to load conversations.',
      );
    }

    final raw = result['conversations'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map(
          (item) => ChatConversation.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<ChatConversation> createDirectConversation(int otherUserId) async {
    final result = await _request('POST', ApiConfig.conversations, {
      'other_user_id': otherUserId,
    });

    if (result['success'] != true || result['conversation'] is! Map) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to start the conversation.',
      );
    }

    return ChatConversation.fromJson(
      Map<String, dynamic>.from(result['conversation'] as Map),
    );
  }

  Future<ChatConversation> createJobConversation(int jobId) async {
    final result = await _request('POST', ApiConfig.conversations, {
      'job_id': jobId,
    });

    if (result['success'] != true || result['conversation'] is! Map) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to create conversation.',
      );
    }

    return ChatConversation.fromJson(
      Map<String, dynamic>.from(result['conversation'] as Map),
    );
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final result = await _request(
      'GET',
      ApiConfig.conversationMessages(conversationId),
    );

    if (result['success'] != true) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to load messages.',
      );
    }

    final raw = result['messages'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ChatMessage> sendTextMessage({
    required int conversationId,
    required String message,
  }) async {
    final result = await _request(
      'POST',
      ApiConfig.conversationMessages(conversationId),
      {'message_type': 'text', 'message': message.trim()},
    );

    if (result['success'] != true || result['chat_message'] is! Map) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to send message.',
      );
    }

    return ChatMessage.fromJson(
      Map<String, dynamic>.from(result['chat_message'] as Map),
    );
  }

  Future<void> markRead(int conversationId) async {
    final result = await _request(
      'PATCH',
      ApiConfig.markConversationRead(conversationId),
    );

    if (result['success'] != true) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to mark messages as read.',
      );
    }
  }

  Future<void> editMessage(int messageId, String message) async {
    final result = await _request('PUT', ApiConfig.message(messageId), {
      'message': message.trim(),
    });

    if (result['success'] != true) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to edit message.',
      );
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final result = await _request('DELETE', ApiConfig.message(messageId));

    if (result['success'] != true) {
      throw ChatServiceException(
        result['message']?.toString() ?? 'Unable to delete message.',
      );
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String url, [
    Map<String, dynamic>? body,
  ]) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Please log in again.'};
    }

    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      late http.Response response;

      if (method == 'POST') {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'PATCH') {
        response = await http.patch(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(Uri.parse(url), headers: headers);
      } else {
        response = await http.get(Uri.parse(url), headers: headers);
      }

      if (response.body.trim().isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{
            'success': false,
            'message': 'Invalid server response.',
          };
    } catch (error) {
      return {
        'success': false,
        'message': 'Unable to connect to the server. $error',
      };
    }
  }
}

class ChatServiceException implements Exception {
  const ChatServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
