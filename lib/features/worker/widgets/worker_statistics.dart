import 'package:flutter/material.dart';

import '../../../models/worker_home_model.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);
const _subText = Color(0xFF6D8092);

class WorkerStatistics extends StatelessWidget {
  const WorkerStatistics({super.key, required this.data});

  final WorkerHomeData data;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        '${data.summary.availableJobs}',
        'Jobs You Can Apply For',
        Icons.work_outline_rounded,
      ),
      (
        '${data.summary.pendingApplications}',
        'Waiting for Reply',
        Icons.hourglass_top_rounded,
      ),
      (
        '${data.summary.activeJobs}',
        'Jobs You Are Doing',
        Icons.handyman_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR WORK',
            style: TextStyle(
              color: _primary,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Work Today',
            style: TextStyle(
              color: _slate,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'See what needs your attention.',
            style: TextStyle(color: _subText, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(items.length, (index) {
              final item = items[index];

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == items.length - 1 ? 0 : 9,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x13000000),
                          blurRadius: 15,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(item.$3, color: _primary, size: 21),
                        const SizedBox(height: 7),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: _slate,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            color: _subText,
                            fontSize: 9.2,
                            height: 1.22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
