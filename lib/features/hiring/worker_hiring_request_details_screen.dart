import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/hiring_service.dart';

const _primary = Color(0xFF1FB8B3);

class WorkerHiringRequestDetailsScreen extends StatefulWidget {
  const WorkerHiringRequestDetailsScreen({super.key, required this.request});

  final Map<String, dynamic> request;

  @override
  State<WorkerHiringRequestDetailsScreen> createState() =>
      _WorkerHiringRequestDetailsScreenState();
}

class _WorkerHiringRequestDetailsScreenState
    extends State<WorkerHiringRequestDetailsScreen> {
  final HiringService _service = HiringService();

  late Map<String, dynamic> _request;
  bool _accepting = false;
  bool _declining = false;

  @override
  void initState() {
    super.initState();
    _request = Map<String, dynamic>.from(widget.request);
  }

  Future<void> _respond({required bool accept}) async {
    final requestId = _asInt(_request['id']);

    if (requestId <= 0) {
      _showMessage('This hiring request is invalid.', error: true);
      return;
    }

    if (accept) {
      setState(() => _accepting = true);
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Decline hiring request?'),
              content: const Text(
                'The homeowner will be informed that you declined this request.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep Request'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  child: const Text('Decline'),
                ),
              ],
            ),
      );

      if (confirmed != true) return;
      setState(() => _declining = true);
    }

    final result =
        accept
            ? await _service.acceptHiringRequest(requestId)
            : await _service.declineHiringRequest(requestId);

    if (!mounted) return;

    setState(() {
      _accepting = false;
      _declining = false;
    });

    if (result['success'] != true) {
      _showMessage(
        result['message']?.toString() ?? 'Unable to update request.',
        error: true,
      );
      return;
    }

    final updated = _map(result['hiring_request']);

    setState(() {
      _request =
          updated.isEmpty
              ? {..._request, 'status': accept ? 'accepted' : 'declined'}
              : updated;
    });

    if (accept) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              icon: const Icon(
                Icons.celebration_rounded,
                color: _primary,
                size: 54,
              ),
              title: const Text('Congratulations!'),
              content: const Text(
                'You accepted this hiring request. The job is now active.',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ],
            ),
      );
    } else {
      _showMessage('Hiring request declined.');
    }

    if (mounted) Navigator.of(context).pop(true);
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

    final job = _map(_request['job']);
    final homeowner = _map(_request['homeowner']);
    final status = _request['status']?.toString() ?? 'pending';
    final pending = status == 'pending';
    final homeownerName = homeowner['full_name']?.toString() ?? 'Homeowner';
    final homeownerPhoto = ApiConfig.storageUrl(
      homeowner['profile_photo']?.toString(),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Hiring Request')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: [
          _HeaderCard(
            homeownerName: homeownerName,
            homeownerPhoto: homeownerPhoto,
            jobTitle: job['title']?.toString() ?? 'Job',
            status: status,
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
                label: 'Offer',
                value: 'UGX ${_money(_request['offered_amount'])}',
              ),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Start Date',
                value: _displayDate(_request['start_date']),
              ),
              _InfoRow(
                icon: Icons.schedule_rounded,
                label: 'Requested',
                value: _relativeTime(_request['created_at']),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoCard(
            title: 'Message from Homeowner',
            children: [
              Text(
                _request['message']?.toString().trim().isNotEmpty == true
                    ? _request['message'].toString()
                    : 'No message was included.',
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.55),
              ),
            ],
          ),
          if ((job['description']?.toString().trim() ?? '').isNotEmpty) ...[
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Job Description',
              children: [
                Text(
                  job['description'].toString(),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar:
          pending
              ? Material(
                color: colors.surface,
                elevation: 14,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _declining
                                    ? null
                                    : () => _respond(accept: false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                            ),
                            icon:
                                _declining
                                    ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.close_rounded),
                            label: Text(
                              _declining ? 'Declining...' : 'Decline',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed:
                                _accepting
                                    ? null
                                    : () => _respond(accept: true),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                            ),
                            icon:
                                _accepting
                                    ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(Icons.check_rounded),
                            label: Text(_accepting ? 'Accepting...' : 'Accept'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.homeownerName,
    required this.homeownerPhoto,
    required this.jobTitle,
    required this.status,
  });

  final String homeownerName;
  final String homeownerPhoto;
  final String jobTitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF164D7A), Color(0xFF177989), Color(0xFF1FB8B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusChip(status: status, onGradient: true),
          const SizedBox(height: 17),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  backgroundImage:
                      homeownerPhoto.isNotEmpty
                          ? NetworkImage(homeownerPhoto)
                          : null,
                  child:
                      homeownerPhoto.isEmpty
                          ? Text(
                            _initials(homeownerName),
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
                      'Hiring request from',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homeownerName,
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
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.work_outline_rounded,
                color: Colors.white70,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
  if (difference.inHours < 1) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours} hr ago';
  }
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
