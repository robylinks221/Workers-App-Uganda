import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'homeowner_applications.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';
import 'services/hiring_service.dart';
import 'features/hiring/worker_hiring_request_details_screen.dart';
import 'features/hiring/homeowner_hiring_request_details_screen.dart';
import 'features/jobs/homeowner_job_lifecycle_screen.dart';
import 'features/jobs/worker_active_job_lifecycle_screen.dart';
import 'homeowner_job_details.dart';
import 'worker_applications.dart';
import 'features/profile/account_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'services/worker_profile_service.dart';
import 'services/app_notification_service.dart';
import 'services/notification_badge_service.dart';

const _primary = Color(0xFF1FB8B3),
    _navy = Color(0xFF17324D),
    _muted = Color(0xFF6D8092),
    _line = Color(0xFFE7EEF3);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = AppNotificationService();
  final _chatService = ChatService();
  final _hiringService = HiringService();
  final _authService = AuthService();
  final _workerProfileService = WorkerProfileService();
  int? _openingId;
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await _service.getNotifications();
    if (!mounted) return;
    setState(() {
      _items =
          (r['notifications'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
      _loading = false;
    });
    NotificationBadgeService.instance.refresh();
  }

  Future<void> _read(Map<String, dynamic> n) async {
    if (n['read_at'] == null) {
      await _service.markRead(n['id'] as int);
      n['read_at'] = DateTime.now().toIso8601String();
      if (mounted) setState(() {});
      NotificationBadgeService.instance.refresh();
    }
  }

  Future<void> _openNotification(Map<String, dynamic> n) async {
    final id = _asInt(n['id']);
    if (id <= 0 || _openingId != null) return;
    setState(() => _openingId = id);
    try {
      await _read(n);
      if (!mounted) return;
      final actionType = '${n['action_type'] ?? ''}'.trim();
      final actionId = _asInt(n['action_id']);
      if (actionType == 'conversation') {
        final conversations = await _chatService.getConversations();
        ChatConversation? target;
        for (final item in conversations) {
          if (item.id == actionId) {
            target = item;
            break;
          }
        }
        if (!mounted) return;
        if (target == null) {
          _message('Conversation not found.');
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatScreen(conversation: target!)),
        );
      } else if (actionType == 'hiring_request' ||
          actionType == 'worker_hiring_request') {
        final result = await _hiringService.getHiringRequest(actionId);
        if (!mounted) return;
        final raw = result['hiring_request'];
        if (result['success'] != true || raw is! Map) {
          _message(
            result['message']?.toString() ?? 'Unable to open this job offer.',
          );
          return;
        }
        final request = Map<String, dynamic>.from(raw);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkerHiringRequestDetailsScreen(request: request),
          ),
        );
      } else if (actionType == 'homeowner_hiring_request') {
        final result = await _hiringService.getHiringRequest(actionId);
        if (!mounted) return;
        final raw = result['hiring_request'];
        if (result['success'] != true || raw is! Map) {
          _message(
            result['message']?.toString() ?? 'Unable to open this job offer.',
          );
          return;
        }
        final request = Map<String, dynamic>.from(raw);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => HomeownerHiringRequestDetailsScreen(request: request),
          ),
        );
      } else if (actionType == 'worker_active_job') {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkerActiveJobLifecycleScreen(jobId: actionId),
          ),
        );
      } else if (actionType == 'homeowner_active_job') {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomeownerJobLifecycleScreen(jobId: actionId),
          ),
        );
      } else if (actionType == 'homeowner_job') {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomeownerJobDetailsScreen(jobId: actionId),
          ),
        );
      } else if (actionType == 'worker_applications') {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkerApplicationsScreen()),
        );
      } else if (actionType == 'job_applications') {
        if (actionId <= 0) {
          _message('Job not found.');
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomeownerApplicationsScreen(jobId: actionId),
          ),
        );
      } else if (actionType == 'worker_profile' ||
          actionType == 'worker_verification' ||
          actionType == 'verification' ||
          actionType == 'account_status' ||
          actionType == 'account_appeal') {
        final user = await _authService.currentUser();
        final profileResult = await _workerProfileService.getProfile();

        if (!mounted) return;

        final rawProfile = profileResult['profile'];

        if (user == null ||
            profileResult['success'] != true ||
            rawProfile is! Map) {
          _message('Unable to open your worker profile.');
          return;
        }

        final profile = Map<String, dynamic>.from(rawProfile);

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) =>
                    AccountScreen(role: 'worker', user: user, profile: profile),
          ),
        );
      } else {
        _message('There is nothing else to open for this update.');
      }
      NotificationBadgeService.instance.refresh();
    } on ChatServiceException catch (e) {
      _message(e.message);
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _all() async {
    await _service.markAllRead();
    for (final n in _items) {
      n['read_at'] ??= DateTime.now().toIso8601String();
    }
    if (mounted) setState(() {});
    NotificationBadgeService.instance.refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F9FB),
    appBar: AppBar(
      title: const Text(
        'Updates',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        if (_items.any((e) => e['read_at'] == null))
          TextButton(onPressed: _all, child: const Text('Mark All Read')),
      ],
    ),
    body:
        _loading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : _items.isEmpty
            ? const _Empty()
            : RefreshIndicator(
              onRefresh: _load,
              color: _primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (c, i) {
                  final n = _items[i], unread = n['read_at'] == null;
                  return Dismissible(
                    key: ValueKey(n['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      await _service.delete(n['id'] as int);
                      _items.remove(n);
                      NotificationBadgeService.instance.refresh();
                    },
                    child: InkWell(
                      onTap:
                          _openingId == _asInt(n['id'])
                              ? null
                              : () => _openNotification(n),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                unread
                                    ? _primary.withValues(alpha: .45)
                                    : _line,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A102A3A),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: .1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _icon('${n['category']}'),
                                color: _primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${n['title'] ?? 'Notification'}',
                                          style: const TextStyle(
                                            color: _navy,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (unread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: _primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${n['body'] ?? ''}',
                                    style: const TextStyle(
                                      color: _muted,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    _relative('${n['created_at'] ?? ''}'),
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (('${n['action_type'] ?? ''}')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 7),
                                    const Row(
                                      children: [
                                        Text(
                                          'Tap to open',
                                          style: TextStyle(
                                            color: _primary,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 13,
                                          color: _primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
  );
  IconData _icon(String c) => switch (c) {
    'messages' => Icons.chat_bubble_outline_rounded,
    'offers' => Icons.handshake_outlined,
    'applications' => Icons.work_outline_rounded,
    'jobs' => Icons.assignment_turned_in_outlined,
    'reviews' => Icons.star_border_rounded,
    'verification' => Icons.verified_user_outlined,
    'account' => Icons.manage_accounts_outlined,
    'appeals' => Icons.rate_review_outlined,
    _ => Icons.notifications_none_rounded,
  };
  String _relative(String v) {
    final d = DateTime.tryParse(v)?.toLocal();
    if (d == null) return '';
    final x = DateTime.now().difference(d);
    if (x.inMinutes < 1) return 'Just now';
    if (x.inHours < 1) return '${x.inMinutes} min ago';
    if (x.inDays < 1)
      return '${x.inHours} ${x.inHours == 1 ? 'hour' : 'hours'} ago';
    return '${x.inDays} ${x.inDays == 1 ? 'day' : 'days'} ago';
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext c) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 54, color: _muted),
          SizedBox(height: 14),
          Text(
            'No updates yet',
            style: TextStyle(
              color: _navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Messages, job offers, applications and important account updates will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    ),
  );
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
