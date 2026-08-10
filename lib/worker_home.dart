import 'package:flutter/material.dart';

import 'features/worker/widgets/worker_active_jobs.dart';
import 'features/worker/widgets/worker_home_header.dart';
import 'features/worker/widgets/worker_job_sections.dart';
import 'features/worker/widgets/worker_quick_actions.dart';
import 'features/worker/widgets/worker_statistics.dart';
import 'features/worker/widgets/worker_filter_options.dart';
import 'services/worker_service_management_service.dart';
import 'features/work_wanted/worker_work_wanted_screen.dart';
import 'models/worker_home_model.dart';
import 'services/worker_home_service.dart';

const _primary = Color(0xFF1FB8B3);
const _slate = Color(0xFF17324D);
const _subText = Color(0xFF718396);
const _navy = Color(0xFF123F67);

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({
    super.key,
    required this.onOpenAccount,
    required this.onOpenApplications,
  });

  final VoidCallback onOpenAccount;
  final VoidCallback onOpenApplications;

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final WorkerHomeService _service = WorkerHomeService();
  final WorkerServiceManagementService _serviceCategories =
      WorkerServiceManagementService();
  final ScrollController _scrollController = ScrollController();

  WorkerHomeData? _data;
  String? _error;
  bool _loading = true;

  String _query = '';
  String? _selectedDistrict;
  String? _selectedCategory;
  bool _urgentOnly = false;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHome() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getHome();

    if (!mounted) return;

    if (result['success'] == true) {
      try {
        setState(() {
          _data = WorkerHomeData.fromJson(result);
          _loading = false;
        });
      } catch (error) {
        setState(() {
          _error = 'Unable to read home data: $error';
          _loading = false;
        });
      }
      return;
    }

    setState(() {
      _error = result['message']?.toString() ?? 'Unable to load worker home.';
      _loading = false;
    });
  }

  List<WorkerHomeJob> _filter(List<WorkerHomeJob> jobs) {
    final query = _query.trim().toLowerCase();

    return jobs.where((job) {
      final homeowner = job.homeowner?.fullName.toLowerCase() ?? '';
      final budget = job.budgetAmount.round().toString();

      final matchesQuery =
          query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.category.toLowerCase().contains(query) ||
          job.district.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query) ||
          job.duration.toLowerCase().contains(query) ||
          homeowner.contains(query) ||
          budget.contains(query) ||
          (query == 'urgent' && job.isUrgent);

      final matchesDistrict =
          _selectedDistrict == null ||
          _selectedDistrict!.isEmpty ||
          job.district == _selectedDistrict;

      final matchesCategory =
          _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          job.category == _selectedCategory;

      final matchesUrgent = !_urgentOnly || job.isUrgent;

      return matchesQuery &&
          matchesDistrict &&
          matchesCategory &&
          matchesUrgent;
    }).toList();
  }

  List<WorkerHomeJob> _allJobs(WorkerHomeData data) {
    final jobs = <WorkerHomeJob>[
      ...data.activeJobs,
      ...data.recommendedJobs,
      ...data.urgentJobs,
      ...data.nearbyJobs,
      ...data.recentJobs,
    ];

    final seen = <int>{};
    return jobs.where((job) => seen.add(job.id)).toList();
  }

  void _scrollToJobs() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      700,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToActiveJobs() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      930,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _showFilters(WorkerHomeData data) async {
    final allJobs = _allJobs(data);

    final districts =
        <String>[
            ...ugandaJobLocations,
            ...allJobs
                .map((job) => job.district.trim())
                .where((value) => value.isNotEmpty),
          ].toSet().toList()
          ..sort();

    final categoryResult = await _serviceCategories.getCategories();

    final categories =
        <String>{
            ...allJobs
                .map((job) => job.category.trim())
                .where((value) => value.isNotEmpty),
            if (categoryResult['success'] == true &&
                categoryResult['service_categories'] is List)
              ...(categoryResult['service_categories'] as List)
                  .whereType<Map>()
                  .map((item) => item['name']?.toString().trim() ?? '')
                  .where((value) => value.isNotEmpty),
          }.toList()
          ..sort();

    String? draftDistrict = _selectedDistrict;
    String? draftCategory = _selectedCategory;
    bool draftUrgent = _urgentOnly;

    final districtController = TextEditingController(text: draftDistrict ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.88,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Find Jobs That Fit You',
                          style: TextStyle(
                            color: _slate,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Search by district, service and urgency.',
                          style: TextStyle(
                            color: _subText,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _ModernFilterLabel(
                          icon: Icons.location_on_outlined,
                          title: 'District',
                          subtitle:
                              'Type a few letters — for example “ka” for Kampala.',
                        ),
                        const SizedBox(height: 10),
                        _DashboardDistrictAutocomplete(
                          controller: districtController,
                          districts: districts,
                          onSelected: (value) {
                            setSheetState(() {
                              draftDistrict = value;
                            });
                          },
                          onCleared: () {
                            districtController.clear();
                            setSheetState(() {
                              draftDistrict = null;
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        const _ModernFilterLabel(
                          icon: Icons.cleaning_services_outlined,
                          title: 'Service',
                          subtitle:
                              'Choose the service category you want to work in.',
                        ),
                        const SizedBox(height: 10),
                        _DashboardServiceSelector(
                          services: categories,
                          selected: draftCategory,
                          onChanged: (value) {
                            setSheetState(() {
                              draftCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8FA),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF39C12,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFF39C12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Urgent jobs only',
                                      style: TextStyle(
                                        color: _slate,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Show only jobs homeowners marked urgent.',
                                      style: TextStyle(
                                        color: _subText,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: draftUrgent,
                                activeColor: _primary,
                                onChanged: (value) {
                                  setSheetState(() {
                                    draftUrgent = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  districtController.clear();
                                  setSheetState(() {
                                    draftDistrict = null;
                                    draftCategory = null;
                                    draftUrgent = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _navy,
                                  minimumSize: const Size.fromHeight(52),
                                  side: const BorderSide(
                                    color: Color(0xFFD9E2E8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedDistrict = draftDistrict;
                                    _selectedCategory = draftCategory;
                                    _urgentOnly = draftUrgent;
                                  });
                                  Navigator.of(sheetContext).pop();
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.tune_rounded),
                                label: const Text(
                                  'Apply Filters',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    districtController.dispose();
  }

  InputDecoration _filterDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_error != null || _data == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 60,
                    color: _primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error ?? 'Unable to load worker home.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _loadHome,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: FilledButton.styleFrom(backgroundColor: _primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final data = _data!;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: RefreshIndicator(
        color: _primary,
        onRefresh: _loadHome,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: WorkerHomeHeader(
                data: data,
                onQueryChanged: (value) {
                  setState(() => _query = value);
                },
                onOpenFilters: () => _showFilters(data),
              ),
            ),
            SliverToBoxAdapter(
              child: _AvailabilityStatusCard(
                availability: data.profile.availability,
                onTap: widget.onOpenAccount,
              ),
            ),
            SliverToBoxAdapter(
              child: WorkerQuickActions(
                onFindJobs: _scrollToJobs,
                onActiveJobs: _scrollToActiveJobs,
                onApplications: widget.onOpenApplications,
                onProfile: widget.onOpenAccount,
              ),
            ),
            SliverToBoxAdapter(child: WorkerStatistics(data: data)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: _LookingForWorkCard(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkerWorkWantedScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: WorkerActiveJobs(jobs: _filter(data.activeJobs)),
            ),
            SliverToBoxAdapter(
              child: WorkerJobSections(
                recommendedJobs: _filter(data.recommendedJobs),
                urgentJobs: _filter(data.urgentJobs),
                nearbyJobs: _filter(data.nearbyJobs),
                recentJobs: _filter(data.recentJobs),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityStatusCard extends StatelessWidget {
  const _AvailabilityStatusCard({
    required this.availability,
    required this.onTap,
  });

  final String availability;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final normalized = availability.trim().toLowerCase();
    final available = normalized == 'available';
    final busy = normalized == 'busy';

    final statusColor =
        available
            ? const Color(0xFF25A56A)
            : busy
            ? const Color(0xFFF39C12)
            : const Color(0xFFE45B63);

    final title =
        available
            ? 'You can work now'
            : busy
            ? 'You are busy'
            : 'You are not available';

    final message =
        available
            ? 'Homeowners can see that you are available for work.'
            : busy
            ? 'Homeowners can see that you are busy right now.'
            : 'Change this when you are ready to receive work.';

    final button = available ? 'Change' : 'I Can Work Now';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Material(
        color: Colors.white,
        elevation: 6,
        shadowColor: _navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(23),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 51,
                  height: 51,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    available
                        ? Icons.check_circle_rounded
                        : busy
                        ? Icons.schedule_rounded
                        : Icons.pause_circle_outline_rounded,
                    color: statusColor,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CAN YOU WORK NOW?',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 9.5,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: const TextStyle(
                          color: _slate,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          color: _subText,
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  button,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernFilterLabel extends StatelessWidget {
  const _ModernFilterLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _slate,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _subText,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardDistrictAutocomplete extends StatefulWidget {
  const _DashboardDistrictAutocomplete({
    required this.controller,
    required this.districts,
    required this.onSelected,
    required this.onCleared,
  });

  final TextEditingController controller;
  final List<String> districts;
  final ValueChanged<String> onSelected;
  final VoidCallback onCleared;

  @override
  State<_DashboardDistrictAutocomplete> createState() =>
      _DashboardDistrictAutocompleteState();
}

class _DashboardDistrictAutocompleteState
    extends State<_DashboardDistrictAutocomplete> {
  String _query = '';

  List<String> get _matches {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) {
      return const <String>[];
    }

    return widget.districts
        .where((district) => district.toLowerCase().contains(query))
        .take(7)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Type district name',
            helperText: 'Example: type “ka” to find Kampala',
            prefixIcon: const Icon(Icons.search_rounded, color: _primary),
            suffixIcon:
                widget.controller.text.isEmpty
                    ? null
                    : IconButton(
                      onPressed: () {
                        widget.onCleared();
                        setState(() {
                          _query = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            filled: true,
            fillColor: const Color(0xFFF4F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < matches.length; i++) ...[
                  InkWell(
                    onTap: () {
                      final district = matches[i];
                      widget.controller.text = district;
                      widget.onSelected(district);

                      setState(() {
                        _query = '';
                      });

                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: _primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              matches[i],
                              style: const TextStyle(
                                color: _slate,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.north_west_rounded,
                            color: _subText,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i != matches.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DashboardServiceSelector extends StatelessWidget {
  const _DashboardServiceSelector({
    required this.services,
    required this.selected,
    required this.onChanged,
  });

  final List<String> services;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => onChanged(value),
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      elevation: 12,
      constraints: const BoxConstraints(
        minWidth: 280,
        maxWidth: 360,
        maxHeight: 380,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) {
        return services.map((service) {
          final active = selected == service;

          return PopupMenuItem<String>(
            value: service,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        active
                            ? _primary.withValues(alpha: 0.12)
                            : const Color(0xFFF4F8FA),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.cleaning_services_outlined,
                    color: active ? _primary : _subText,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    service,
                    style: TextStyle(
                      color: active ? _primary : _slate,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
                if (active)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _primary,
                    size: 19,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FA),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cleaning_services_outlined,
                color: _primary,
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                selected ?? 'Select a service',
                style: TextStyle(
                  color: selected == null ? _subText : _slate,
                  fontSize: 13,
                  fontWeight:
                      selected == null ? FontWeight.w600 : FontWeight.w900,
                ),
              ),
            ),
            if (selected != null)
              IconButton(
                onPressed: () => onChanged(null),
                icon: const Icon(
                  Icons.close_rounded,
                  color: _subText,
                  size: 18,
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
          ],
        ),
      ),
    );
  }
}

class _LookingForWorkCard extends StatelessWidget {
  const _LookingForWorkCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F466A), Color(0xFF176F82), Color(0xFF1FB8B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF123F67).withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -34,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOOKING FOR WORK?',
                          style: TextStyle(
                            color: Color(0xFFC8F4F0),
                            fontSize: 9.5,
                            letterSpacing: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tell Homeowners You Need Work',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tell homeowners what kind of work you are looking for.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: _primary,
                      size: 20,
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
