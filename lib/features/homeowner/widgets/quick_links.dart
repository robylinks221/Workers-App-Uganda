import 'package:flutter/material.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);

class QuickLinks extends StatelessWidget {
  const QuickLinks({
    super.key,
    required this.onBrowseWorkers,
    required this.onPostJob,
    required this.onMyJobs,
    required this.onSavedWorkers,
  });

  final VoidCallback onBrowseWorkers;
  final VoidCallback onPostJob;
  final VoidCallback onMyJobs;
  final VoidCallback onSavedWorkers;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickLinkData(
        icon: Icons.person_search_outlined,
        title: 'Find a Worker',
        subtitle: 'Browse approved workers',
        onTap: onBrowseWorkers,
      ),
      _QuickLinkData(
        icon: Icons.add_task_rounded,
        title: 'Post a Job',
        subtitle: 'Tell workers what help you need',
        onTap: onPostJob,
      ),
      _QuickLinkData(
        icon: Icons.work_history_outlined,
        title: 'Jobs I Posted',
        subtitle: 'See applicants and active jobs',
        onTap: onMyJobs,
      ),
      _QuickLinkData(
        icon: Icons.favorite_border_rounded,
        title: 'Saved Workers',
        subtitle: 'See workers you liked',
        onTap: onSavedWorkers,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT DO YOU NEED?',
            style: TextStyle(
              color: _primary,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose what you want to do',
            style: TextStyle(
              color: _slate,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap one of the boxes below.',
            style: TextStyle(color: _muted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.16,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 8,
                shadowColor: _navy.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: _primary, size: 23),
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13.2,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLinkData {
  const _QuickLinkData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
