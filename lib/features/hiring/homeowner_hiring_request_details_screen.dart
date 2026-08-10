import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/hiring_service.dart';
import '../jobs/homeowner_job_lifecycle_screen.dart';

const _primary = Color(0xFF1FB8B3);

class HomeownerHiringRequestDetailsScreen extends StatefulWidget {
  const HomeownerHiringRequestDetailsScreen({super.key, required this.request});

  final Map<String, dynamic> request;

  @override
  State<HomeownerHiringRequestDetailsScreen> createState() =>
      _HomeownerHiringRequestDetailsScreenState();
}

class _HomeownerHiringRequestDetailsScreenState
    extends State<HomeownerHiringRequestDetailsScreen> {
  final HiringService _service = HiringService();

  late Map<String, dynamic> _request;
  bool _cancelling = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _request = Map<String, dynamic>.from(widget.request);
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel This Job Offer?'),
            content: const Text(
              'The worker will no longer be able to accept this job offer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Offer'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: const Text('Cancel Offer'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _cancelling = true);

    final result = await _service.cancelHiringRequest(_asInt(_request['id']));

    if (!mounted) return;

    setState(() => _cancelling = false);

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ?? 'Unable to cancel request.',
        error: true,
      );
      return;
    }

    _showMessage('Job offer cancelled.');
    Navigator.of(context).pop(true);
  }

  Future<void> _complete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mark job as completed?'),
            content: const Text(
              'Only continue when the work has been completed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Yet'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Mark Completed'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _completing = true);

    final result = await _service.completeHiringRequest(_asInt(_request['id']));

    if (!mounted) return;

    setState(() => _completing = false);

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ?? 'Unable to complete job.',
        error: true,
      );
      return;
    }

    _showMessage('Job marked as completed.');
    Navigator.of(context).pop(true);
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final worker = _map(_request['worker']);
    final job = _map(_request['job']);
    final status = _request['status']?.toString() ?? 'pending';

    final workerName = worker['full_name']?.toString() ?? 'Worker';
    final workerPhoto = ApiConfig.storageUrl(
      worker['profile_photo']?.toString(),
    );

    final canCancel = status == 'pending';
    final canComplete = [
      'accepted',
      'in_progress',
      'awaiting_confirmation',
      'completed',
    ].contains(status);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Job Offer Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF164D7A),
                  Color(0xFF177989),
                  Color(0xFF1FB8B3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChip(status: status, onGradient: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 31,
                        backgroundColor: Colors.white24,
                        backgroundImage:
                            workerPhoto.isNotEmpty
                                ? NetworkImage(workerPhoto)
                                : null,
                        child:
                            workerPhoto.isEmpty
                                ? Text(
                                  _initials(workerName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Worker',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            workerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WhiteInfo(
                  icon: Icons.work_outline_rounded,
                  text: job['title']?.toString() ?? 'Job',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: job['district']?.toString() ?? 'Not provided',
              ),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: 'Your Offer',
                value: 'UGX ${_money(_request['offered_amount'])}',
              ),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Start Date',
                value: _displayDate(_request['start_date']),
              ),
              _InfoRow(
                icon: Icons.schedule_rounded,
                label: 'Sent',
                value: _relativeTime(_request['created_at']),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoCard(
            title: 'Message Sent',
            children: [
              Text(
                (_request['message']?.toString().trim() ?? '').isEmpty
                    ? 'You did not add a message to this offer.'
                    : _request['message'].toString(),
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.55),
              ),
            ],
          ),
          if (status == 'accepted' || status == 'in_progress') ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16A957).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A957)),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'The worker accepted your job offer.',
                      style: TextStyle(
                        color: Color(0xFF16A957),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == 'declined') ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'The worker declined your job offer.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar:
          (canCancel || canComplete)
              ? Material(
                color: colors.surface,
                elevation: 14,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    child:
                        canCancel
                            ? OutlinedButton.icon(
                              onPressed: _cancelling ? null : _cancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                              ),
                              icon:
                                  _cancelling
                                      ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.close_rounded),
                              label: Text(
                                _cancelling ? 'Cancelling...' : 'Cancel Offer',
                              ),
                            )
                            : FilledButton.icon(
                              onPressed: () {
                                final jobId = _asInt(job['id']);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => HomeownerJobLifecycleScreen(
                                          jobId: jobId,
                                        ),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                              ),
                              icon:
                                  _completing
                                      ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(Icons.task_alt_rounded),
                              label: Text('Open Active Job'),
                            ),
                  ),
                ),
              )
              : null,
    );
  }
}

class _WhiteInfo extends StatelessWidget {
  const _WhiteInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 13),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.onGradient = false});

  final String status;
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'accepted':
      case 'in_progress':
        color = const Color(0xFF36D98B);
        break;
      case 'declined':
      case 'cancelled':
        color = const Color(0xFFFF7B7B);
        break;
      case 'completed':
        color = const Color(0xFF79C8FF);
        break;
      default:
        color = const Color(0xFFFFC44D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color:
            onGradient
                ? Colors.white.withValues(alpha: 0.16)
                : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: TextStyle(
          color: onGradient ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _money(dynamic value) {
  final amount = double.tryParse(value?.toString() ?? '') ?? 0;
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

String _label(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return 'Not provided';

  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) =>
            word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _displayDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Not specified';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _relativeTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Recently';

  final difference = DateTime.now().difference(date);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes} min ago';
  if (difference.inDays < 1) return '${difference.inHours} hr ago';
  if (difference.inDays == 1) return 'Yesterday';
  if (difference.inDays < 7) return '${difference.inDays} days ago';

  return _displayDate(value);
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
