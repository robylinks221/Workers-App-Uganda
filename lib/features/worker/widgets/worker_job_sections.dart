import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../models/worker_home_model.dart';
import '../../../worker_all_jobs.dart';
import '../../../worker_job_details.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);
const _subText = Color(0xFF6D8092);
const _line = Color(0xFFE7EEF3);
const _amber = Color(0xFFF39C12);

class WorkerJobSections extends StatelessWidget {
  const WorkerJobSections({
    super.key,
    required this.recommendedJobs,
    required this.urgentJobs,
    required this.nearbyJobs,
    required this.recentJobs,
  });

  final List<WorkerHomeJob> recommendedJobs;
  final List<WorkerHomeJob> urgentJobs;
  final List<WorkerHomeJob> nearbyJobs;
  final List<WorkerHomeJob> recentJobs;

  List<WorkerHomeJob> get _allJobs {
    final combined = <WorkerHomeJob>[
      ...recentJobs,
      ...recommendedJobs,
      ...urgentJobs,
      ...nearbyJobs,
    ];

    final seen = <int>{};

    return combined.where((job) => seen.add(job.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allJobs = _allJobs;

    final preview =
        recentJobs.isNotEmpty
            ? recentJobs.take(5).toList()
            : allJobs.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIND WORK',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Jobs for You',
                      style: TextStyle(
                        color: _slate,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'These are new jobs from homeowners. Tap a job to read it and apply.',
                      style: TextStyle(
                        color: _subText,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (allJobs.isNotEmpty)
                TextButton(
                  onPressed: () => _openAll(context, allJobs),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (preview.isEmpty)
            const _Empty()
          else
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
                  for (var index = 0; index < preview.length; index++) ...[
                    _NewJobRow(job: preview[index]),
                    if (index != preview.length - 1)
                      const Divider(height: 1, indent: 76, color: _line),
                  ],
                ],
              ),
            ),
          if (allJobs.length > 5) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openAll(context, allJobs),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.work_outline_rounded, size: 18),
                label: Text(
                  'View All ${allJobs.length} Jobs',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openAll(BuildContext context, List<WorkerHomeJob> jobs) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => WorkerAllJobsScreen(jobs: jobs)));
  }
}

class _NewJobRow extends StatelessWidget {
  const _NewJobRow({required this.job});

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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _slate,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
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
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _displayPostedTime(job.postedAt),
                        style: const TextStyle(
                          color: _subText,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _slate,
                            fontSize: 15,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (job.isUrgent) ...[
                        const SizedBox(width: 5),
                        const Icon(Icons.bolt_rounded, color: _amber, size: 18),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: _subText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.district,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _subText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 14,
                              color: _primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Open',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _openJob(context),
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Job',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.arrow_forward_rounded, size: 15),
                          ],
                        ),
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
      MaterialPageRoute(builder: (_) => WorkerJobDetailsScreen(jobId: job.id)),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(Icons.inbox_rounded, color: _primary, size: 30),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'There are no new jobs right now. Check again later.',
              style: TextStyle(color: _subText),
            ),
          ),
        ],
      ),
    );
  }
}

String _displayPostedTime(String value) {
  final clean = value.trim();

  if (clean.isEmpty) {
    return 'Recently';
  }

  final lower = clean.toLowerCase();

  if (lower.contains('ago') ||
      lower == 'just now' ||
      lower == 'today' ||
      lower == 'yesterday') {
    return clean;
  }

  final parsed = DateTime.tryParse(clean);

  if (parsed == null) {
    return clean;
  }

  final posted = parsed.toLocal();
  final now = DateTime.now();
  final difference = now.difference(posted);

  if (difference.isNegative || difference.inMinutes < 1) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
  }

  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }

  if (difference.inDays < 30) {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  }

  if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }

  final years = (difference.inDays / 365).floor();

  return '$years ${years == 1 ? 'year' : 'years'} ago';
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

  if (parts.isEmpty) {
    return 'H';
  }

  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}
