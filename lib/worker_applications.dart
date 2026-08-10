import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'services/worker_job_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class WorkerApplicationsScreen extends StatefulWidget {
  const WorkerApplicationsScreen({super.key});

  @override
  State<WorkerApplicationsScreen> createState() =>
      _WorkerApplicationsScreenState();
}

class _WorkerApplicationsScreenState extends State<WorkerApplicationsScreen> {
  final WorkerJobService _service = WorkerJobService();

  List<Map<String, dynamic>> _applications = [];
  final Set<int> _working = {};
  bool _loading = true;
  String? _error;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getApplications();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error =
            result['message']?.toString() ?? 'Unable to load applications.';
        _loading = false;
      });
      return;
    }

    final raw = result['applications'];

    setState(() {
      _applications =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : <Map<String, dynamic>>[];
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _invitations {
    return _applications
        .where((item) => item['invited_by_homeowner'] == true)
        .toList();
  }

  List<Map<String, dynamic>> get _submitted {
    return _applications
        .where((item) => item['invited_by_homeowner'] != true)
        .toList();
  }

  Future<void> _accept(Map<String, dynamic> item) async {
    await _runAction(
      item: item,
      title: 'Take this job?',
      message:
          'Do you want to take this job? If you accept, you may not be available for another active job.',
      actionLabel: 'Accept',
      request: _service.acceptInvitation,
    );
  }

  Future<void> _decline(Map<String, dynamic> item) async {
    await _runAction(
      item: item,
      title: 'Say No to This Job?',
      message: 'Are you sure you do not want this job?',
      actionLabel: 'Decline',
      destructive: true,
      request: _service.declineInvitation,
    );
  }

  Future<void> _withdraw(Map<String, dynamic> item) async {
    await _runAction(
      item: item,
      title: 'Cancel My Application?',
      message: 'Are you sure you want to cancel this application?',
      actionLabel: 'Withdraw',
      destructive: true,
      request: _service.withdrawApplication,
    );
  }

  Future<void> _runAction({
    required Map<String, dynamic> item,
    required String title,
    required String message,
    required String actionLabel,
    required Future<Map<String, dynamic>> Function(int id) request,
    bool destructive = false,
  }) async {
    final id = _asInt(item['id']);
    if (id <= 0 || _working.contains(id)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: destructive ? Colors.red.shade700 : _primary,
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _working.add(id));
    final result = await request(id);

    if (!mounted) return;

    setState(() => _working.remove(id));

    _show(
      result['message']?.toString() ?? 'Request completed.',
      success: result['success'] == true,
    );

    if (result['success'] == true) {
      await _load();
    }
  }

  void _show(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? _navy : Colors.red.shade700,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final invitations = _invitations;
    final submitted = _submitted;
    final visible = _selectedTab == 0 ? invitations : submitted;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ApplicationsHeader(
              invitations: invitations.length,
              applications: submitted.length,
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: _load,
            ),
            _ApplicationsTabs(
              selectedIndex: _selectedTab,
              invitations: invitations.length,
              applications: submitted.length,
              onChanged: (value) {
                setState(() => _selectedTab = value);
              },
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(color: _primary),
                      )
                      : _error != null
                      ? _ApplicationState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Unable to load applications',
                        message: _error!,
                        buttonLabel: 'Try Again',
                        onPressed: _load,
                      )
                      : visible.isEmpty
                      ? _ApplicationState(
                        icon:
                            _selectedTab == 0
                                ? Icons.mail_outline_rounded
                                : Icons.description_outlined,
                        title:
                            _selectedTab == 0
                                ? 'No homeowner requests yet'
                                : 'You have not applied for a job yet',
                        message:
                            _selectedTab == 0
                                ? 'When a homeowner asks you to work, you will see it here.'
                                : 'Jobs you apply for will appear here while you wait for a reply.',
                      )
                      : RefreshIndicator(
                        color: _primary,
                        onRefresh: _load,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                          itemCount: visible.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 13),
                          itemBuilder: (_, index) {
                            final item = visible[index];
                            final invited =
                                item['invited_by_homeowner'] == true;
                            final status =
                                item['status']?.toString() ?? 'pending';

                            return _ApplicationCard(
                              item: item,
                              invited: invited,
                              loading: _working.contains(_asInt(item['id'])),
                              onAccept:
                                  invited && status == 'pending'
                                      ? () => _accept(item)
                                      : null,
                              onDecline:
                                  invited && status == 'pending'
                                      ? () => _decline(item)
                                      : null,
                              onWithdraw:
                                  !invited && status == 'pending'
                                      ? () => _withdraw(item)
                                      : null,
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationsHeader extends StatelessWidget {
  const _ApplicationsHeader({
    required this.invitations,
    required this.applications,
    required this.onBack,
    required this.onRefresh,
  });

  final int invitations;
  final int applications;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      padding: const EdgeInsets.fromLTRB(8, 10, 10, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jobs & Replies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'See homeowners who want you and jobs you applied for.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  icon: Icons.mail_outline_rounded,
                  value: invitations,
                  label: 'Homeowners Want Me',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderMetric(
                  icon: Icons.assignment_outlined,
                  value: applications,
                  label: 'I Applied',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 9),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationsTabs extends StatelessWidget {
  const _ApplicationsTabs({
    required this.selectedIndex,
    required this.invitations,
    required this.applications,
    required this.onChanged,
  });

  final int selectedIndex;
  final int invitations;
  final int applications;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Homeowners Want Me',
              count: invitations,
              active: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Jobs I Applied For',
              count: applications,
              active: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient:
              active
                  ? const LinearGradient(colors: [Color(0xFF177989), _primary])
                  : null,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white : colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color:
                    active
                        ? Colors.white.withValues(alpha: 0.18)
                        : _primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? Colors.white : _primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.item,
    required this.invited,
    required this.loading,
    required this.onAccept,
    required this.onDecline,
    required this.onWithdraw,
  });

  final Map<String, dynamic> item;
  final bool invited;
  final bool loading;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final job = _map(item['job']);
    final homeowner = _map(job['homeowner']);
    final status = item['status']?.toString() ?? 'pending';

    final homeownerName = homeowner['full_name']?.toString() ?? 'Homeowner';
    final homeownerPhoto = ApiConfig.storageUrl(
      homeowner['profile_photo']?.toString(),
    );

    return Material(
      color: colors.surface,
      elevation: 6,
      shadowColor: Colors.black.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.30 : 0.11,
      ),
      borderRadius: BorderRadius.circular(23),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: _primary.withValues(alpha: 0.12),
                    backgroundImage:
                        homeownerPhoto.isNotEmpty
                            ? NetworkImage(homeownerPhoto)
                            : null,
                    child:
                        homeownerPhoto.isEmpty
                            ? Text(
                              _initials(homeownerName),
                              style: const TextStyle(
                                color: _primary,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        invited
                            ? 'This homeowner wants you'
                            : 'You applied for this job',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              job['title']?.toString() ?? 'Job',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  text: job['district']?.toString() ?? 'Location not provided',
                ),
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  text: job['duration']?.toString() ?? 'Duration not provided',
                ),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  text: 'UGX ${_money(job['budget_amount'])}',
                ),
              ],
            ),
            if ((item['message']?.toString() ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  item['message'].toString(),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (loading) ...[
              const SizedBox(height: 15),
              const LinearProgressIndicator(color: _primary),
            ] else if (onAccept != null && onDecline != null) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else if (onWithdraw != null) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Withdraw Application'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'accepted':
        color = const Color(0xFF16A957);
        break;
      case 'declined':
      case 'withdrawn':
        color = const Color(0xFFD63031);
        break;
      default:
        color = const Color(0xFFFFA000);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationState extends StatelessWidget {
  const _ApplicationState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _primary, size: 62),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 17),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
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

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
