import 'dart:async';

import 'package:flutter/foundation.dart';

import 'chat_service.dart';
import 'app_notification_service.dart';
import 'hiring_service.dart';
import 'worker_job_service.dart';

class NotificationBadgeService extends ChangeNotifier {
  NotificationBadgeService._();

  static final NotificationBadgeService instance = NotificationBadgeService._();

  final ChatService _chatService = ChatService();
  final HiringService _hiringService = HiringService();
  final WorkerJobService _workerJobService = WorkerJobService();
  final AppNotificationService _notificationService = AppNotificationService();

  Timer? _timer;
  bool _refreshing = false;
  String _role = '';

  int _unreadMessages = 0;
  int _pendingHiringRequests = 0;
  int _unreadNotifications = 0;

  int get unreadMessages => _unreadMessages;
  int get pendingHiringRequests => _pendingHiringRequests;
  int get unreadNotifications => _unreadNotifications;

  void startForRole(String role) {
    _role = role;
    _timer?.cancel();

    refresh();

    _timer = Timer.periodic(const Duration(seconds: 20), (_) => refresh());
  }

  Future<void> refresh() async {
    if (_refreshing || _role.isEmpty) return;

    _refreshing = true;

    try {
      final conversations = await _chatService.getConversations();
      final notificationCount = await _notificationService.unreadCount();
      final unread = conversations.fold<int>(
        0,
        (total, conversation) => total + conversation.unreadCount,
      );

      var pendingRequests = 0;

      if (_role == 'worker') {
        final hiringResult = await _hiringService.getWorkerHiringRequests();
        final applicationsResult = await _workerJobService.getApplications();

        if (hiringResult['success'] == true &&
            hiringResult['hiring_requests'] is List) {
          final requests = hiringResult['hiring_requests'] as List;
          pendingRequests +=
              requests.where((request) {
                if (request is! Map) return false;
                return request['status']?.toString() == 'pending';
              }).length;
        }

        if (applicationsResult['success'] == true &&
            applicationsResult['applications'] is List) {
          final applications = applicationsResult['applications'] as List;
          pendingRequests +=
              applications.where((application) {
                if (application is! Map) return false;
                return application['invited_by_homeowner'] != true &&
                    application['status']?.toString() == 'pending';
              }).length;
        }
      }

      final changed =
          unread != _unreadMessages ||
          pendingRequests != _pendingHiringRequests ||
          notificationCount != _unreadNotifications;

      _unreadMessages = unread;
      _pendingHiringRequests = pendingRequests;
      _unreadNotifications = notificationCount;

      if (changed) notifyListeners();
    } catch (_) {
      // Keep the previous visible counters if a temporary API request fails.
    } finally {
      _refreshing = false;
    }
  }

  Future<void> refreshAfterMessageRead() async {
    if (_refreshing) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    await refresh();

    if (_refreshing) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await refresh();
    }
  }

  void clearRequestBadge() {
    if (_pendingHiringRequests == 0) return;
    _pendingHiringRequests = 0;
    notifyListeners();
  }

  void clearMessageBadge() {
    if (_unreadMessages == 0) return;
    _unreadMessages = 0;
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
