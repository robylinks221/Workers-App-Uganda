import 'package:flutter/material.dart';

import '../../../config/api_config.dart';

const _slate = Color(0xFF17324D);

class NewWorkersCarousel extends StatelessWidget {
  const NewWorkersCarousel({
    super.key,
    required this.workers,
    required this.onViewAll,
    required this.onOpenWorker,
    required this.onToggleSaved,
  });

  final List<Map<String, dynamic>> workers;
  final VoidCallback onViewAll;
  final ValueChanged<Map<String, dynamic>> onOpenWorker;
  final ValueChanged<Map<String, dynamic>> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    if (workers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEW PROFILES',
                        style: TextStyle(
                          color: Color(0xFF1FB8B3),
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'New Workers',
                        style: TextStyle(
                          color: _slate,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recently approved workers who joined the app.',
                        style: TextStyle(
                          color: Color(0xFF718396),
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
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 360,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.72),
              itemCount: workers.length,
              padEnds: false,
              itemBuilder: (_, index) {
                final worker = workers[index];

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == workers.length - 1 ? 18 : 14,
                    bottom: 8,
                  ),
                  child: _NewWorkerCard(
                    worker: worker,
                    onOpen: () => onOpenWorker(worker),
                    onSave: () => onToggleSaved(worker),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NewWorkerCard extends StatelessWidget {
  const _NewWorkerCard({
    required this.worker,
    required this.onSave,
    required this.onOpen,
  });

  final Map<String, dynamic> worker;
  final VoidCallback onSave;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final name = worker['full_name']?.toString() ?? 'Worker';
    final imageUrl = ApiConfig.storageUrl(worker['profile_photo']?.toString());
    final saved = worker['is_saved'] == true;
    final saving = worker['saving'] == true;
    final available = worker['availability']?.toString() == 'available';
    final joinedLabel = _joinedLabel(worker['created_at']);

    String service = 'Domestic Service';
    final services = worker['services'];
    if (services is List && services.isNotEmpty) {
      final first = _map(services.first);
      service = first['name']?.toString() ?? service;
    }

    final district =
        worker['district']?.toString() ??
        worker['location']?.toString() ??
        'Location not provided';

    return Material(
      color: Colors.transparent,
      elevation: 6,
      shadowColor: const Color(0x28000000),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => const _WorkerImageFallback(),
              )
            else
              const _WorkerImageFallback(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00000000),
                    Color(0x22000000),
                    Color(0xEE000000),
                  ],
                  stops: [0.36, 0.56, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 13,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF15B85A),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.24),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: saving ? null : onSave,
                  icon:
                      saving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(
                            saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color:
                                saved ? const Color(0xFFFF6680) : Colors.white,
                          ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (joinedLabel.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            joinedLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB300),
                        size: 19,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${worker['rating'] ?? '0.00'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${worker['total_reviews'] ?? 0})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text('•', style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 9),
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          district,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (available) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF168F49),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerImageFallback extends StatelessWidget {
  const _WorkerImageFallback();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? const [Color(0xFF20313E), Color(0xFF0F5560)]
                  : const [Color(0xFF8CCFCB), Color(0xFF164D7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
          size: 72,
        ),
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
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(onPressed: onAction, child: const Text('View All')),
      ],
    );
  }
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
