import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'features/marketplace/browse_workers_screen.dart';
import 'features/profile/worker_public_profile_screen.dart';
import 'services/saved_workers_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class SavedWorkersScreen extends StatefulWidget {
  const SavedWorkersScreen({super.key});

  @override
  State<SavedWorkersScreen> createState() => _SavedWorkersScreenState();
}

class _SavedWorkersScreenState extends State<SavedWorkersScreen> {
  final SavedWorkersService _service = SavedWorkersService();
  final TextEditingController _search = TextEditingController();

  List<Map<String, dynamic>> _workers = [];
  final Set<int> _removing = {};
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getSavedWorkers();
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error =
            result['message']?.toString() ?? 'Unable to load favorite workers.';
        _loading = false;
      });
      return;
    }

    final raw = result['saved_workers'] ?? result['workers'] ?? result['data'];
    final workers = <Map<String, dynamic>>[];

    if (raw is List) {
      for (final item in raw) {
        final value = _map(item);
        final nested = _map(value['worker']);
        workers.add(nested.isNotEmpty ? nested : value);
      }
    }

    setState(() {
      _workers = workers;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _workers;

    return _workers.where((worker) {
      final name = worker['full_name']?.toString().toLowerCase() ?? '';
      final district =
          (worker['district'] ?? worker['location'])
              ?.toString()
              .toLowerCase() ??
          '';
      final services = _services(worker).join(' ').toLowerCase();

      return name.contains(query) ||
          district.contains(query) ||
          services.contains(query);
    }).toList();
  }

  Future<void> _remove(Map<String, dynamic> worker) async {
    final workerId = int.tryParse(worker['id']?.toString() ?? '');
    if (workerId == null || _removing.contains(workerId)) return;

    setState(() => _removing.add(workerId));
    final result = await _service.removeWorker(workerId);

    if (!mounted) return;

    setState(() => _removing.remove(workerId));
    final success = result['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ?? 'Favorite worker request completed.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? _navy : Colors.red.shade700,
      ),
    );

    if (success) {
      setState(() {
        _workers.removeWhere(
          (item) => item['id']?.toString() == workerId.toString(),
        );
      });
    }
  }

  void _openWorker(Map<String, dynamic> worker) {
    final workerId = int.tryParse(worker['id']?.toString() ?? '');
    if (workerId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerPublicProfileScreen(workerId: workerId),
      ),
    );
  }

  void _browseWorkers() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BrowseWorkersScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workers = _filtered;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SavedHeader(
              count: _workers.length,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(color: _primary),
                      )
                      : _error != null
                      ? _ErrorState(message: _error!, onRetry: _loadWorkers)
                      : RefreshIndicator(
                        color: _primary,
                        onRefresh: _loadWorkers,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                          children: [
                            Material(
                              elevation: 5,
                              shadowColor: Colors.black.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                              child: TextField(
                                controller: _search,
                                onChanged: (value) {
                                  setState(() => _query = value);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search saved workers',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon:
                                      _query.isEmpty
                                          ? null
                                          : IconButton(
                                            onPressed: () {
                                              _search.clear();
                                              setState(() => _query = '');
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                            ),
                                          ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_workers.isEmpty)
                              _EmptyState(onBrowse: _browseWorkers)
                            else if (workers.isEmpty)
                              const _NoSearchResults()
                            else
                              ...workers.map(
                                (worker) => _SavedWorkerCard(
                                  worker: worker,
                                  removing: _removing.contains(
                                    int.tryParse(
                                          worker['id']?.toString() ?? '',
                                        ) ??
                                        -1,
                                  ),
                                  onOpen: () => _openWorker(worker),
                                  onRemove: () => _remove(worker),
                                ),
                              ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedHeader extends StatelessWidget {
  const _SavedHeader({required this.count, required this.onBack});

  final int count;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF177989), _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Workers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count saved worker${count == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedWorkerCard extends StatelessWidget {
  const _SavedWorkerCard({
    required this.worker,
    required this.removing,
    required this.onOpen,
    required this.onRemove,
  });

  final Map<String, dynamic> worker;
  final bool removing;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = worker['full_name']?.toString() ?? 'Worker';
    final imageUrl = ApiConfig.storageUrl(worker['profile_photo']?.toString());
    final district =
        (worker['district'] ?? worker['location'])?.toString() ??
        'Location not provided';
    final services = _services(worker);

    return Material(
      color: colors.surface,
      elevation: 6,
      shadowColor: Colors.black.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.30 : 0.11,
      ),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child:
                          imageUrl.isEmpty
                              ? Text(
                                _initials(name),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (worker['is_verified'] == true)
                              const Icon(
                                Icons.verified_rounded,
                                color: _primary,
                                size: 19,
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          district,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB300),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              worker['rating']?.toString() ?? '0.00',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (services.isNotEmpty) ...[
                const SizedBox(height: 13),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children:
                        services.take(4).map((service) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.11),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              service,
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(backgroundColor: _primary),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  IconButton.outlined(
                    tooltip: 'Remove saved worker',
                    onPressed: removing ? null : onRemove,
                    icon:
                        removing
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFE94877),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_border_rounded, color: _primary, size: 55),
          const SizedBox(height: 13),
          Text(
            'No Saved Workers Yet',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save workers you like so you can compare and contact them later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onBrowse,
            style: FilledButton.styleFrom(backgroundColor: _primary),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Browse Workers'),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: _primary, size: 45),
          SizedBox(height: 10),
          Text(
            'No saved workers match your search.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
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

List<String> _services(Map<String, dynamic> worker) {
  final raw = worker['services'] ?? _map(worker['profile'])['services'];
  if (raw is! List) return const [];

  return raw
      .map((item) {
        if (item is String) return item;
        return _map(item)['name']?.toString() ?? '';
      })
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isEmpty ? '?' : name[0].toUpperCase();
}
