import 'package:flutter/material.dart';

import '../../services/worker_service_management_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class WorkerServicesScreen extends StatefulWidget {
  const WorkerServicesScreen({super.key});

  @override
  State<WorkerServicesScreen> createState() => _WorkerServicesScreenState();
}

class _WorkerServicesScreenState extends State<WorkerServicesScreen> {
  final _service = WorkerServiceManagementService();

  List<Map<String, dynamic>> _categories = const [];
  Set<int> _selectedIds = <int>{};
  Set<int> _initialIds = <int>{};

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await Future.wait([
      _service.getCategories(),
      _service.getSelectedServices(),
    ]);

    if (!mounted) return;

    final categoriesResult = results[0];
    final selectedResult = results[1];

    if (categoriesResult['success'] != true ||
        selectedResult['success'] != true) {
      setState(() {
        _error =
            categoriesResult['message']?.toString() ??
            selectedResult['message']?.toString() ??
            'Unable to load services.';
        _loading = false;
      });
      return;
    }

    final categories = <Map<String, dynamic>>[];
    final rawCategories = categoriesResult['service_categories'];

    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map) {
          categories.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final selectedIds = <int>{};
    final rawSelected = selectedResult['selected_service_ids'];

    if (rawSelected is List) {
      for (final item in rawSelected) {
        final id = int.tryParse(item.toString());
        if (id != null) selectedIds.add(id);
      }
    }

    setState(() {
      _categories = categories;
      _selectedIds = {...selectedIds};
      _initialIds = {...selectedIds};
      _loading = false;
    });
  }

  bool get _hasChanges =>
      _selectedIds.length != _initialIds.length ||
      !_selectedIds.containsAll(_initialIds);

  Future<void> _save() async {
    if (!_hasChanges) {
      _showMessage('No changes made.', success: false);
      return;
    }

    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one service.', success: false);
      return;
    }

    setState(() => _saving = true);

    final ids = _selectedIds.toList()..sort();
    final result = await _service.updateServices(ids);

    if (!mounted) return;
    setState(() => _saving = false);

    final success = result['success'] == true;
    _showMessage(
      result['message']?.toString() ?? 'Services updated.',
      success: success,
    );

    if (success) Navigator.of(context).pop(true);
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? _navy : Colors.orange.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ServicesHeader(selectedCount: _selectedIds.length),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(color: _primary),
                      )
                      : _error != null
                      ? _ErrorView(message: _error!, onRetry: _load)
                      : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        itemCount: _categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 13,
                              crossAxisSpacing: 13,
                              childAspectRatio: 1.12,
                            ),
                        itemBuilder: (_, index) {
                          final category = _categories[index];
                          final id =
                              int.tryParse(category['id']?.toString() ?? '') ??
                              0;
                          final selected = _selectedIds.contains(id);

                          return _ServiceCard(
                            title: category['name']?.toString() ?? 'Service',
                            description:
                                category['description']?.toString() ?? '',
                            icon: _iconFor(category['icon']?.toString()),
                            selected: selected,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedIds.remove(id);
                                } else {
                                  _selectedIds.add(id);
                                }
                              });
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        color: theme.colorScheme.surface,
        elevation: 16,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: _primary),
                icon:
                    _saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving...' : 'Save Services'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicesHeader extends StatelessWidget {
  const _ServicesHeader({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
            onPressed: () => Navigator.of(context).maybePop(),
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
              Icons.cleaning_services_outlined,
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
                  'Services Offered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$selectedCount selected • Tap cards to update',
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient:
                selected
                    ? const LinearGradient(
                      colors: [Color(0xFF177989), Color(0xFF1FB8B3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: selected ? null : colors.surface,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color:
                    selected
                        ? _primary.withValues(alpha: 0.28)
                        : Colors.black.withValues(
                          alpha:
                              theme.brightness == Brightness.dark ? 0.24 : 0.09,
                        ),
                blurRadius: selected ? 18 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: selected ? Colors.white : _primary,
                    size: 31,
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : colors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            selected ? Colors.white70 : colors.onSurfaceVariant,
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
              if (selected)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _primary, size: 58),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(String? icon) {
  switch (icon) {
    case 'cleaning_services':
      return Icons.cleaning_services_outlined;
    case 'local_laundry_service':
      return Icons.local_laundry_service_outlined;
    case 'child_care':
      return Icons.child_care_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'elderly':
      return Icons.elderly_outlined;
    case 'yard':
      return Icons.yard_outlined;
    case 'security':
      return Icons.security_outlined;
    case 'directions_car':
      return Icons.directions_car_outlined;
    case 'business':
      return Icons.business_outlined;
    case 'hotel':
      return Icons.hotel_outlined;
    case 'volunteer_activism':
      return Icons.volunteer_activism_outlined;
    case 'family_restroom':
      return Icons.family_restroom_outlined;
    case 'agriculture':
      return Icons.agriculture_outlined;
    case 'pets':
      return Icons.pets_outlined;
    default:
      return Icons.work_outline_rounded;
  }
}
