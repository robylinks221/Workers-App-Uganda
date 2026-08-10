import 'package:flutter/material.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);

class WorkerQuickActions extends StatelessWidget {
  const WorkerQuickActions({
    super.key,
    required this.onFindJobs,
    required this.onActiveJobs,
    required this.onApplications,
    required this.onProfile,
  });

  final VoidCallback onFindJobs;
  final VoidCallback onActiveJobs;
  final VoidCallback onApplications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickAction(
        icon: Icons.search_rounded,
        title: 'Find Work',
        subtitle: 'See jobs near you',
        accent: _primary,
        onTap: onFindJobs,
      ),
      _QuickAction(
        icon: Icons.mark_email_read_outlined,
        title: 'Jobs I Applied For',
        subtitle: 'See homeowner replies',
        accent: const Color(0xFF7865D6),
        onTap: onApplications,
      ),
      _QuickAction(
        icon: Icons.work_history_outlined,
        title: 'Jobs I Am Doing',
        subtitle: 'See your current work',
        accent: const Color(0xFF3F82E3),
        onTap: onActiveJobs,
      ),
      _QuickAction(
        icon: Icons.person_outline_rounded,
        title: 'My Profile',
        subtitle: 'Check or update your details',
        accent: const Color(0xFFE66A78),
        onTap: onProfile,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT DO YOU WANT TO DO?',
            style: TextStyle(
              color: _primary,
              fontSize: 10,
              letterSpacing: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose an action',
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
              childAspectRatio: 1.18,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 9,
                shadowColor: _navy.withValues(alpha: 0.12),
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
                            color: item.accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.accent, size: 23),
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
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

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
}
