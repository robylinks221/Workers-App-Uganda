import 'package:flutter/material.dart';

import '../../../config/api_config.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF17324D);
const _sub = Color(0xFF6D8092);
const _line = Color(0xFFE7EEF3);

class WorkWantedPreview extends StatelessWidget {
  const WorkWantedPreview({
    super.key,
    required this.posts,
    required this.onViewAll,
    required this.onOpenWorker,
  });
  final List<Map<String, dynamic>> posts;
  final VoidCallback onViewAll;
  final ValueChanged<Map<String, dynamic>> onOpenWorker;

  @override
  Widget build(BuildContext context) {
    final preview = posts.take(5).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
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
                      'AVAILABLE NOW',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Workers Looking for Work',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'These workers have said they are currently looking for work.',
                      style: TextStyle(color: _sub, fontSize: 11, height: 1.35),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 10),
          if (preview.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: const Text(
                'No workers are looking for work right now. Check again later.',
                style: TextStyle(color: _sub),
              ),
            )
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
                  for (var i = 0; i < preview.length; i++) ...[
                    _WorkerRow(
                      post: preview[i],
                      onTap: () => onOpenWorker(preview[i]),
                    ),
                    if (i != preview.length - 1)
                      const Divider(height: 1, indent: 76, color: _line),
                  ],
                ],
              ),
            ),
          if (posts.length > 5) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewAll,
                icon: const Icon(Icons.person_search_rounded),
                label: Text('View All ${posts.length} Workers'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkerRow extends StatelessWidget {
  const _WorkerRow({required this.post, required this.onTap});
  final Map<String, dynamic> post;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final worker =
        post['worker'] is Map
            ? Map<String, dynamic>.from(post['worker'])
            : <String, dynamic>{};
    final name =
        worker['full_name']?.toString().trim().isNotEmpty == true
            ? worker['full_name'].toString()
            : 'Worker';
    final photo = ApiConfig.storageUrl(worker['profile_photo']?.toString());
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _primary.withValues(alpha: .10),
              backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
              child:
                  photo.isEmpty
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
                                  color: _navy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (worker['is_verified'] == true) ...const [
                              SizedBox(width: 4),
                              Icon(
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
                        _timeAgo(post['created_at']?.toString()),
                        style: const TextStyle(color: _sub, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    post['title']?.toString() ?? 'Looking for Work',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: _sub,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          post['district']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _sub, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'AVAILABLE',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'See Worker',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: _primary,
                        size: 15,
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
}

String _timeAgo(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'Recently';
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  final x = DateTime.now().difference(d.toLocal());
  if (x.inMinutes < 1) return 'Just now';
  if (x.inHours < 1) return '${x.inMinutes} min ago';
  if (x.inDays < 1)
    return '${x.inHours} ${x.inHours == 1 ? 'hour' : 'hours'} ago';
  if (x.inDays < 30) return '${x.inDays} ${x.inDays == 1 ? 'day' : 'days'} ago';
  final m = (x.inDays / 30).floor();
  return '$m ${m == 1 ? 'month' : 'months'} ago';
}

String _initials(String n) {
  final p = n.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  return p.isEmpty ? 'W' : p.take(2).map((e) => e[0].toUpperCase()).join();
}
