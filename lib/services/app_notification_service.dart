import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../storage/token_storage.dart';

class AppNotificationService {
  Future<Map<String, dynamic>> _request(String method, String url) async {
    final token = await TokenStorage.getToken();
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    late http.Response r;
    if (method == 'GET')
      r = await http.get(Uri.parse(url), headers: headers);
    else if (method == 'DELETE')
      r = await http.delete(Uri.parse(url), headers: headers);
    else
      r = await http.post(Uri.parse(url), headers: headers);
    final data =
        r.body.trim().isEmpty
            ? <String, dynamic>{}
            : jsonDecode(r.body) as Map<String, dynamic>;
    return {...data, 'success': r.statusCode >= 200 && r.statusCode < 300};
  }

  Future<Map<String, dynamic>> getNotifications() =>
      _request('GET', ApiConfig.notifications);
  Future<int> unreadCount() async {
    try {
      final r = await _request('GET', ApiConfig.notificationUnreadCount);
      return r['unread_count'] is int
          ? r['unread_count']
          : int.tryParse('${r['unread_count']}') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markRead(int id) async {
    await _request('POST', ApiConfig.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _request('POST', ApiConfig.notificationReadAll);
  }

  Future<void> delete(int id) async {
    await _request('DELETE', ApiConfig.notification(id));
  }
}
