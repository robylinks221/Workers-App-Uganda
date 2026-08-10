import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../job_chat_launcher.dart';
import '../../../models/worker_home_model.dart';
import '../../jobs/worker_active_job_lifecycle_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);
const _subText = Color(0xFF6D8092);
const _line = Color(0xFFE7EEF3);

class WorkerActiveJobs extends StatelessWidget {
  const WorkerActiveJobs({super.key, required this.jobs});

  final List<WorkerHomeJob> jobs;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MY WORK',
            style: TextStyle(
              color: _primary,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Jobs I Am Doing',
            style: TextStyle(
              color: _slate,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Open a job to see what you need to do next.',
            style: TextStyle(color: _subText, fontSize: 11, height: 1.35),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D102A3A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var index = 0; index < jobs.length; index++) ...[
                  _ActiveJobRow(job: jobs[index]),
                  if (index != jobs.length - 1)
                    const Divider(height: 1, indent: 76, color: _line),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobRow extends StatelessWidget {
  const _ActiveJobRow({required this.job});

  final WorkerHomeJob job;

  @override
  Widget build(BuildContext context) {
    final homeowner = job.homeowner;
    final name =
        homeowner?.fullName.trim().isNotEmpty == true
            ? homeowner!.fullName
            : 'Homeowner';
    final photoUrl = ApiConfig.storageUrl(homeowner?.profilePhoto);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openJob(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _primary.withValues(alpha: 0.10),
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child:
                  photoUrl.isEmpty
                      ? Text(
                        _initials(name),
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                      : null,
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
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _slate,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(status: job.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _subText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (homeowner?.isVerified == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: _primary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      _Meta(Icons.location_on_outlined, job.district),
                      _Meta(
                        Icons.payments_outlined,
                        'UGX ${_money(job.budgetAmount)}',
                      ),
                      if (job.startDate.trim().isNotEmpty)
                        _Meta(
                          Icons.calendar_month_outlined,
                          _displayDate(job.startDate),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed:
                            () => JobChatLauncher.open(
                              context: context,
                              jobId: job.id,
                            ),
                        style: TextButton.styleFrom(
                          foregroundColor: _slate,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                        ),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 17,
                        ),
                        label: const Text('Message'),
                      ),
                      const SizedBox(width: 18),
                      TextButton.icon(
                        onPressed: () => _openJob(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 17),
                        label: const Text('See What To Do'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openJob(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerActiveJobLifecycleScreen(jobId: job.id),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF218C54),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _subText),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: _subText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

String _money(double amount) {
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

String _displayDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value.contains('T') ? value.split('T').first : value;

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

String _statusLabel(String status) {
  switch (status) {
    case 'in_progress':
      return 'IN PROGRESS';
    case 'accepted':
      return 'ACCEPTED';
    default:
      return status.replaceAll('_', ' ').toUpperCase();
  }
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return 'H';
  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}
