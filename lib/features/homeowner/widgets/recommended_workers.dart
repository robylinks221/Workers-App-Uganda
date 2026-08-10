import 'package:flutter/material.dart';

import '../../../config/api_config.dart';

const _subText = Color(0xFF6D8092);
const _navy = Color(0xFF164D7A);

class RecommendedWorkers extends StatelessWidget {
  const RecommendedWorkers({
    super.key,
    required this.workers,
    required this.loading,
    required this.onViewAll,
    required this.onOpenWorker,
    required this.onToggleSaved,
  });

  final List<Map<String, dynamic>> workers;
  final bool loading;
  final VoidCallback onViewAll;
  final ValueChanged<Map<String, dynamic>> onOpenWorker;
  final ValueChanged<Map<String, dynamic>> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKERS FOR YOU',
                      style: TextStyle(
                        color: Color(0xFF1FB8B3),
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Recommended Workers',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Approved workers you may want to consider.',
                      style: TextStyle(
                        color: _subText,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 14),
          if (loading)
            const _LoadingList()
          else if (workers.isEmpty)
            const _EmptyList()
          else
            ...workers
                .take(4)
                .map(
                  (worker) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecommendedWorkerCard(
                      worker: worker,
                      onOpen: () => onOpenWorker(worker),
                      onSave: () => onToggleSaved(worker),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _RecommendedWorkerCard extends StatelessWidget {
  const _RecommendedWorkerCard({
    required this.worker,
    required this.onSave,
    required this.onOpen,
  });

  final Map<String, dynamic> worker;
  final VoidCallback onSave;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText = isDark ? const Color(0xFFB2C0CE) : _subText;

    final name = worker['full_name']?.toString() ?? 'Worker';
    final imageUrl = ApiConfig.storageUrl(worker['profile_photo']?.toString());
    final saved = worker['is_saved'] == true;
    final saving = worker['saving'] == true;
    final available = worker['availability']?.toString() == 'available';
    final joinedLabel = _joinedLabel(worker['created_at']);
    final verified =
        worker['is_verified'] == true ||
        worker['verified'] == true ||
        worker['verification_status']?.toString() == 'verified';

    String service = 'Domestic Service';
    final services = worker['services'];
    if (services is List && services.isNotEmpty) {
      service = _map(services.first)['name']?.toString() ?? service;
    }

    final district =
        worker['district']?.toString() ??
        worker['location']?.toString() ??
        'Location not provided';

    return Material(
      color: colors.surface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor:
                    isDark
                        ? colors.surfaceContainerHighest
                        : const Color(0xFFE8F8F7),
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child:
                    imageUrl.isEmpty
                        ? Text(
                          _initials(name),
                          style: TextStyle(
                            color: isDark ? colors.onSurface : _navy,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF16A957),
                            size: 19,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondaryText, fontSize: 12),
                    ),
                    if (joinedLabel.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: secondaryText,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              joinedLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${worker['rating'] ?? '0.00'}',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${worker['total_reviews'] ?? 0})',
                          style: TextStyle(color: secondaryText, fontSize: 10),
                        ),
                        const SizedBox(width: 10),
                        Text('•', style: TextStyle(color: secondaryText)),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_outlined,
                          color: secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            district,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (available)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF174E36)
                            : const Color(0xFFE5F8EC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Available',
                    style: TextStyle(
                      color:
                          isDark
                              ? const Color(0xFF8BE3B0)
                              : const Color(0xFF25834E),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Material(
                color: colors.surface,
                elevation: 2,
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  onPressed: saving ? null : onSave,
                  icon:
                      saving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(
                            saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color:
                                saved ? const Color(0xFFE94877) : secondaryText,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 98,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: placeholder,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'No recommended workers yet.',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAction});

  final String title;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(onPressed: onAction, child: const Text('See All')),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _joinedLabel(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return '';

  final joined = DateTime.tryParse(raw)?.toLocal();
  if (joined == null) return '';

  final now = DateTime.now();
  var difference = now.difference(joined);

  if (difference.isNegative) {
    difference = Duration.zero;
  }

  if (difference.inMinutes < 1) {
    return 'Joined just now';
  }

  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return 'Joined $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  }

  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return 'Joined $hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }

  if (difference.inDays == 1) {
    return 'Joined yesterday';
  }

  if (difference.inDays < 7) {
    return 'Joined ${difference.inDays} days ago';
  }

  if (difference.inDays < 14) {
    return 'Joined last week';
  }

  if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return 'Joined $weeks weeks ago';
  }

  if (difference.inDays < 60) {
    return 'Joined last month';
  }

  if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return 'Joined $months months ago';
  }

  if (difference.inDays < 730) {
    return 'Joined last year';
  }

  final years = (difference.inDays / 365).floor();
  return 'Joined $years years ago';
}
