import 'package:flutter/material.dart';

import 'homeowner_applications.dart';
import 'homeowner_job_details.dart';
import 'services/homeowner_job_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class HomeownerJobsScreen extends StatefulWidget {
  const HomeownerJobsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<HomeownerJobsScreen> createState() => _HomeownerJobsScreenState();
}

class _HomeownerJobsScreenState extends State<HomeownerJobsScreen> {
  final HomeownerJobService _service = HomeownerJobService();

  List<Map<String, dynamic>> _jobs = [];
  bool _loading = true;
  String? _error;
  int? _deletingJobId;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getJobs();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error =
            result['message']?.toString() ?? 'We could not load your jobs.';
        _loading = false;
      });
      return;
    }

    final raw = result['jobs'];

    setState(() {
      _jobs =
          raw is List
              ? raw
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : <Map<String, dynamic>>[];
      _loading = false;
    });
  }

  Future<void> _openDetails(Map<String, dynamic> job) async {
    final jobId = _asInt(job['id']);
    if (jobId <= 0) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HomeownerJobDetailsScreen(jobId: jobId),
      ),
    );

    if (changed == true || mounted) {
      await _loadJobs();
    }
  }

  Future<void> _deleteJob(Map<String, dynamic> job) async {
    final jobId = _asInt(job['id']);
    if (jobId <= 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete This Job?'),
            content: Text(
              'Delete "${job['title'] ?? 'this job'}"? '
              'You will not be able to restore this job after deleting it.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _deletingJobId = jobId);

    final result = await _service.deleteJob(jobId);

    if (!mounted) return;

    setState(() => _deletingJobId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? 'Done.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            result['success'] == true ? _navy : Colors.red.shade700,
      ),
    );

    if (result['success'] == true) {
      await _loadJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar:
          widget.embedded
              ? null
              : AppBar(
                title: const Text('Jobs I Posted'),
                backgroundColor: colors.surface,
                foregroundColor: colors.onSurface,
              ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!),
                ),
              )
              : _jobs.isEmpty
              ? const _EmptyJobs()
              : RefreshIndicator(
                color: _primary,
                onRefresh: _loadJobs,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                  itemCount: _jobs.length,
                  itemBuilder: (_, index) {
                    final job = _jobs[index];
                    return _JobCard(
                      job: job,
                      deleting: _deletingJobId == _asInt(job['id']),
                      onView: () => _openDetails(job),
                      onEdit: () => _openDetails(job),
                      onApplications: () {
                        final id = _asInt(job['id']);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => HomeownerApplicationsScreen(jobId: id),
                          ),
                        );
                      },
                      onDelete: () => _deleteJob(job),
                    );
                  },
                ),
              ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.deleting,
    required this.onView,
    required this.onEdit,
    required this.onApplications,
    required this.onDelete,
  });

  final Map<String, dynamic> job;
  final bool deleting;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onApplications;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;

    final status = job['status']?.toString() ?? 'open';
    final services =
        job['service_categories'] is List
            ? job['service_categories'] as List
            : const [];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.14),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job['title']?.toString() ?? 'Job',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 15, color: muted),
              const SizedBox(width: 5),
              Text(
                'Posted ${_postedDate(job['created_at'])}',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (services.isNotEmpty)
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children:
                  services
                      .whereType<Map>()
                      .take(4)
                      .map(
                        (raw) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? _primary.withValues(alpha: 0.14)
                                    : const Color(0xFFEAF7F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            raw['name']?.toString() ?? 'Service',
                            style: TextStyle(
                              color: isDark ? _primary : _navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Info(
                  icon: Icons.location_on_outlined,
                  text: job['district']?.toString() ?? 'No district',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Info(
                  icon: Icons.work_outline_rounded,
                  text: _label(job['work_arrangement'] ?? job['duration']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Info(
            icon: Icons.payments_outlined,
            text:
                'UGX ${_money(job['budget_amount'])} • ${_label(job['budget_type'])}',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              OutlinedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Details'),
              ),
              if (status == 'open' || status == 'cancelled')
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Change Job Details'),
                ),
              if (status == 'open')
                OutlinedButton.icon(
                  onPressed: onApplications,
                  icon: const Icon(Icons.people_outline_rounded),
                  label: const Text('People Who Applied'),
                ),
              if (status == 'open' || status == 'cancelled')
                OutlinedButton.icon(
                  onPressed: deleting ? null : onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                  icon:
                      deleting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color background;
    Color foreground;

    switch (status) {
      case 'accepted':
      case 'in_progress':
        background = isDark ? const Color(0xFF174E36) : const Color(0xFFE4F7EA);
        foreground = isDark ? const Color(0xFF8BE3B0) : const Color(0xFF23804D);
        break;
      case 'completed':
        background = isDark ? const Color(0xFF18384F) : const Color(0xFFE8F1FB);
        foreground = isDark ? const Color(0xFF83C7F4) : _navy;
        break;
      case 'cancelled':
        background = Theme.of(context).colorScheme.surfaceContainerHighest;
        foreground = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
      default:
        background =
            isDark ? _primary.withValues(alpha: 0.15) : const Color(0xFFEAF7F7);
        foreground = _primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          'You have not posted any jobs yet.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
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
  final text = value?.toString() ?? '';
  return text
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (part) =>
            part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _postedDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();

  if (date == null) return 'recently';

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) return 'just now';
  if (difference.inHours < 1) {
    return '${difference.inMinutes} minutes ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours} hours ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  }

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
