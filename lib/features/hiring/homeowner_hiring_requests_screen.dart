import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/hiring_service.dart';
import 'homeowner_hiring_request_details_screen.dart';

const _primary = Color(0xFF1FB8B3);

class HomeownerHiringRequestsScreen extends StatefulWidget {
  const HomeownerHiringRequestsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<HomeownerHiringRequestsScreen> createState() =>
      _HomeownerHiringRequestsScreenState();
}

class _HomeownerHiringRequestsScreenState
    extends State<HomeownerHiringRequestsScreen> {
  final HiringService _service = HiringService();

  bool _loading = true;
  String? _error;
  String _filter = 'all';
  List<Map<String, dynamic>> _requests = const [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getHomeownerHiringRequests();

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error =
            result['message']?.toString() ?? 'Unable to load your job offers.';
        _loading = false;
      });
      return;
    }

    final raw = result['hiring_requests'];
    final items = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final value in raw) {
        if (value is Map) {
          items.add(Map<String, dynamic>.from(value));
        }
      }
    }

    setState(() {
      _requests = items;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _requests;

    return _requests
        .where((item) => item['status']?.toString() == _filter)
        .toList();
  }

  Future<void> _open(Map<String, dynamic> request) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HomeownerHiringRequestDetailsScreen(request: request),
      ),
    );

    if (changed == true) await _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar:
          widget.embedded
              ? null
              : AppBar(
                title: const Text('Job Offers I Sent'),
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loadRequests,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : _error != null
              ? _MessageState(
                icon: Icons.cloud_off_rounded,
                title: 'Unable to load job offers',
                message: _error!,
                buttonLabel: 'Try Again',
                onPressed: _loadRequests,
              )
              : RefreshIndicator(
                color: _primary,
                onRefresh: _loadRequests,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 0, 12),
                        child: SizedBox(
                          height: 42,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _FilterChip(
                                label: 'All',
                                value: 'all',
                                selected: _filter,
                                onTap: _setFilter,
                              ),
                              _FilterChip(
                                label: 'Pending',
                                value: 'pending',
                                selected: _filter,
                                onTap: _setFilter,
                              ),
                              _FilterChip(
                                label: 'Accepted',
                                value: 'accepted',
                                selected: _filter,
                                onTap: _setFilter,
                              ),
                              _FilterChip(
                                label: 'Declined',
                                value: 'declined',
                                selected: _filter,
                                onTap: _setFilter,
                              ),
                              _FilterChip(
                                label: 'Completed',
                                value: 'completed',
                                selected: _filter,
                                onTap: _setFilter,
                              ),
                              const SizedBox(width: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_filtered.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _MessageState(
                          icon: Icons.handshake_outlined,
                          title: 'No Job Offers Yet',
                          message:
                              _filter == 'all'
                                  ? 'When you offer a worker a job, you can follow the response here.'
                                  : 'There are no ${_label(_filter).toLowerCase()} requests.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
                        sliver: SliverList.separated(
                          itemCount: _filtered.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 13),
                          itemBuilder: (_, index) {
                            final request = _filtered[index];

                            return _HiringCard(
                              request: request,
                              onTap: () => _open(request),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  void _setFilter(String value) {
    if (value == _filter) return;
    setState(() => _filter = value);
  }
}

class _HiringCard extends StatelessWidget {
  const _HiringCard({required this.request, required this.onTap});

  final Map<String, dynamic> request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final worker = _map(request['worker']);
    final job = _map(request['job']);
    final status = request['status']?.toString() ?? 'pending';

    final workerName = worker['full_name']?.toString() ?? 'Worker';
    final workerPhoto = ApiConfig.storageUrl(
      worker['profile_photo']?.toString(),
    );

    return Material(
      color: colors.surface,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      radius: 25,
                      backgroundColor: _primary.withValues(alpha: 0.13),
                      backgroundImage:
                          workerPhoto.isNotEmpty
                              ? NetworkImage(workerPhoto)
                              : null,
                      child:
                          workerPhoto.isEmpty
                              ? Text(
                                _initials(workerName),
                                style: const TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.w800,
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
                          workerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _relativeTime(
                            request['updated_at'] ?? request['created_at'],
                          ),
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                job['title']?.toString() ?? 'Job',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              _Meta(
                icon: Icons.location_on_outlined,
                text: job['district']?.toString() ?? 'Location not provided',
              ),
              const SizedBox(height: 7),
              _Meta(
                icon: Icons.payments_outlined,
                text: 'UGX ${_money(request['offered_amount'])}',
              ),
              if (status == 'accepted' || status == 'in_progress') ...[
                const SizedBox(height: 12),
                _ResultBanner(
                  text: 'Worker accepted your job offer',
                  color: const Color(0xFF16A957),
                  icon: Icons.check_circle_rounded,
                ),
              ],
              if (status == 'declined') ...[
                const SizedBox(height: 12),
                _ResultBanner(
                  text: 'Worker declined your job offer',
                  color: Colors.red.shade700,
                  icon: Icons.cancel_rounded,
                ),
              ],
              const SizedBox(height: 13),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'View Details →',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
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

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(value),
        selectedColor: _primary.withValues(alpha: 0.16),
        labelStyle: TextStyle(
          color: active ? _primary : colors.onSurfaceVariant,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(color: active ? _primary : colors.outlineVariant),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, color: muted, size: 16),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'accepted':
      case 'in_progress':
        color = const Color(0xFF16A957);
        break;
      case 'declined':
      case 'cancelled':
        color = const Color(0xFFD63031);
        break;
      case 'completed':
        color = const Color(0xFF2878B5);
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
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
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
            Icon(icon, color: _primary, size: 64),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
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

String _relativeTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Recently';

  final difference = DateTime.now().difference(date);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes} min ago';
  if (difference.inDays < 1) return '${difference.inHours} hr ago';
  if (difference.inDays == 1) return 'Yesterday';
  if (difference.inDays < 7) return '${difference.inDays} days ago';

  return '${date.day}/${date.month}/${date.year}';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
