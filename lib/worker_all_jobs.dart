import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'features/worker/widgets/worker_filter_options.dart';
import 'models/worker_home_model.dart';
import 'services/worker_service_management_service.dart';
import 'worker_job_details.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _deepNavy = Color(0xFF0C2D4B);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _bg = Color(0xFFF4F7FA);
const _orange = Color(0xFFF28C45);
const _purple = Color(0xFF7865D6);
const _green = Color(0xFF2AA36B);

class WorkerAllJobsScreen extends StatefulWidget {
  const WorkerAllJobsScreen({super.key, required this.jobs});

  final List<WorkerHomeJob> jobs;

  @override
  State<WorkerAllJobsScreen> createState() => _WorkerAllJobsScreenState();
}

class _WorkerAllJobsScreenState extends State<WorkerAllJobsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final WorkerServiceManagementService _serviceManager =
      WorkerServiceManagementService();

  String _query = '';
  String? _district;
  String? _category;
  bool _urgentOnly = false;

  List<String> _serviceNames = const <String>[];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final result = await _serviceManager.getCategories();

    if (!mounted || result['success'] != true) {
      return;
    }

    final raw = result['service_categories'];

    if (raw is! List) {
      return;
    }

    final names =
        raw
            .whereType<Map>()
            .map((item) => item['name']?.toString().trim() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    setState(() {
      _serviceNames = names;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkerHomeJob> get _filteredJobs {
    final query = _query.trim().toLowerCase();

    return widget.jobs.where((job) {
      final homeowner = job.homeowner?.fullName.toLowerCase() ?? '';

      final matchesQuery =
          query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.category.toLowerCase().contains(query) ||
          job.district.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query) ||
          homeowner.contains(query);

      final matchesDistrict =
          _district == null ||
          job.district.toLowerCase().contains(_district!.toLowerCase());

      final matchesCategory =
          _category == null ||
          job.category.toLowerCase() == _category!.toLowerCase();

      final matchesUrgent = !_urgentOnly || job.isUrgent;

      return matchesQuery &&
          matchesDistrict &&
          matchesCategory &&
          matchesUrgent;
    }).toList();
  }

  int get _activeFilterCount =>
      (_district != null ? 1 : 0) +
      (_category != null ? 1 : 0) +
      (_urgentOnly ? 1 : 0);

  Future<void> _showFilters() async {
    String? draftDistrict = _district;
    String? draftCategory = _category;
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
                    maxHeight: MediaQuery.sizeOf(context).height * 0.86,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
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
                              color: const Color(0xFFDCE4E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Find the right job',
                          style: TextStyle(
                            color: _slate,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Narrow jobs by location, service and urgency.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),

                        const _FilterLabel(
                          icon: Icons.location_on_outlined,
                          title: 'District',
                          subtitle:
                              'Start typing, for example “ka” for Kampala.',
                        ),
                        const SizedBox(height: 10),

                        _SearchableDistrictField(
                          controller: districtController,
                          initialValue: draftDistrict,
                          onSelected: (value) {
                            setSheetState(() {
                              draftDistrict = value;
                            });
                          },
                          onCleared: () {
                            setSheetState(() {
                              draftDistrict = null;
                              districtController.clear();
                            });
                          },
                        ),

                        const SizedBox(height: 22),

                        const _FilterLabel(
                          icon: Icons.cleaning_services_outlined,
                          title: 'Service',
                          subtitle: 'Choose the type of work you want.',
                        ),
                        const SizedBox(height: 10),

                        _StyledServiceSelector(
                          services: _serviceNames,
                          selected: draftCategory,
                          onChanged: (value) {
                            setSheetState(() {
                              draftCategory = value;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FA),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _orange.withValues(alpha: 0.11),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.flash_on_rounded,
                                  color: _orange,
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
                                      'Show jobs marked as urgent by homeowners.',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 10.5,
                                        height: 1.3,
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
                                  setSheetState(() {
                                    draftDistrict = null;
                                    draftCategory = null;
                                    draftUrgent = false;
                                    districtController.clear();
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _navy,
                                  minimumSize: const Size.fromHeight(52),
                                  side: const BorderSide(
                                    color: Color(0xFFD7E1E7),
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
                                    _district = draftDistrict;
                                    _category = draftCategory;
                                    _urgentOnly = draftUrgent;
                                  });

                                  Navigator.pop(sheetContext);
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

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(jobs.length),
            _filterSummary(),
            Expanded(
              child:
                  jobs.isEmpty
                      ? const _JobsEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                        itemCount: jobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, index) {
                          return _PremiumJobCard(job: jobs[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_deepNavy, _navy, Color(0xFF1B8E94)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -45,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIND WORK',
                          style: TextStyle(
                            color: Color(0xFFB7D9E2),
                            fontSize: 9.5,
                            letterSpacing: 1.45,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Jobs Near You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count jobs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose a job that fits\nyour skills and location.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(17),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _query = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search jobs',
                          hintStyle: const TextStyle(
                            color: _muted,
                            fontSize: 12.5,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _primary,
                          ),
                          suffixIcon:
                              _query.isEmpty
                                  ? null
                                  : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _query = '';
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Badge(
                    isLabelVisible: _activeFilterCount > 0,
                    label: Text(_activeFilterCount.toString()),
                    child: Material(
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(17),
                      child: InkWell(
                        onTap: _showFilters,
                        borderRadius: BorderRadius.circular(17),
                        child: const SizedBox(
                          width: 54,
                          height: 54,
                          child: Icon(Icons.tune_rounded, color: _primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterSummary() {
    if (_activeFilterCount == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Jobs You Can Apply For',
                style: TextStyle(
                  color: _slate,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _showFilters,
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: const Text('Filter'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 58,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        scrollDirection: Axis.horizontal,
        children: [
          if (_district != null)
            _ActiveFilterChip(
              label: _district!,
              icon: Icons.location_on_outlined,
              onRemove: () {
                setState(() {
                  _district = null;
                });
              },
            ),
          if (_category != null)
            _ActiveFilterChip(
              label: _category!,
              icon: Icons.cleaning_services_outlined,
              onRemove: () {
                setState(() {
                  _category = null;
                });
              },
            ),
          if (_urgentOnly)
            _ActiveFilterChip(
              label: 'Urgent',
              icon: Icons.flash_on_rounded,
              onRemove: () {
                setState(() {
                  _urgentOnly = false;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _SearchableDistrictField extends StatelessWidget {
  const _SearchableDistrictField({
    required this.controller,
    required this.initialValue,
    required this.onSelected,
    required this.onCleared,
  });

  final TextEditingController controller;
  final String? initialValue;
  final ValueChanged<String> onSelected;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();

        if (query.isEmpty) {
          return ugandaJobLocations.take(8);
        }

        return ugandaJobLocations
            .where((district) => district.toLowerCase().contains(query))
            .take(8);
      },
      displayStringForOption: (option) => option,
      onSelected: onSelected,
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (_) => onFieldSubmitted(),
          decoration: InputDecoration(
            hintText: 'Type district name',
            prefixIcon: const Icon(Icons.search_rounded, color: _primary),
            suffixIcon:
                textEditingController.text.isEmpty
                    ? null
                    : IconButton(
                      onPressed: onCleared,
                      icon: const Icon(Icons.close_rounded),
                    ),
            filled: true,
            fillColor: const Color(0xFFF5F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelectedOption, options) {
        final values = options.toList();

        if (values.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 12,
            shadowColor: _navy.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 360),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 7),
                shrinkWrap: true,
                itemCount: values.length,
                separatorBuilder:
                    (_, __) => const Divider(height: 1, indent: 52),
                itemBuilder: (_, index) {
                  final district = values[index];

                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: _primary,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      district,
                      style: const TextStyle(
                        color: _slate,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () => onSelectedOption(district),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StyledServiceSelector extends StatelessWidget {
  const _StyledServiceSelector({
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
      onSelected: onChanged,
      color: Colors.white,
      elevation: 12,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      constraints: const BoxConstraints(
        minWidth: 280,
        maxWidth: 360,
        maxHeight: 360,
      ),
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
                            : const Color(0xFFF4F7F9),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.cleaning_services_outlined,
                    color: active ? _primary : _muted,
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FA),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
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
                  color: selected == null ? _muted : _slate,
                  fontSize: 13,
                  fontWeight:
                      selected == null ? FontWeight.w600 : FontWeight.w900,
                ),
              ),
            ),
            if (selected != null)
              IconButton(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close_rounded, color: _muted, size: 18),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
          ],
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({
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
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.1),
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
                  color: _muted,
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InputChip(
        avatar: Icon(icon, color: _primary, size: 16),
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close_rounded, size: 16),
        deleteIconColor: _primary,
        side: BorderSide.none,
        backgroundColor: _primary.withValues(alpha: 0.09),
        labelStyle: const TextStyle(
          color: _primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PremiumJobCard extends StatelessWidget {
  const _PremiumJobCard({required this.job});

  final WorkerHomeJob job;

  @override
  Widget build(BuildContext context) {
    final homeowner = job.homeowner;
    final homeownerName =
        homeowner?.fullName.trim().isNotEmpty == true
            ? homeowner!.fullName
            : 'Homeowner';

    final profilePhoto = ApiConfig.storageUrl(homeowner?.profilePhoto);

    return Material(
      color: Colors.white,
      elevation: 7,
      shadowColor: _navy.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkerJobDetailsScreen(jobId: job.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _primary.withValues(alpha: 0.1),
                    backgroundImage:
                        profilePhoto.isNotEmpty
                            ? NetworkImage(profilePhoto)
                            : null,
                    child:
                        profilePhoto.isEmpty
                            ? Text(
                              _initials(homeownerName),
                              style: const TextStyle(
                                color: _primary,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                homeownerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _slate,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (homeowner?.isVerified == true) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: _primary,
                                size: 15,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job.postedAt.trim().isEmpty
                              ? 'Recently posted'
                              : job.postedAt,
                          style: const TextStyle(color: _muted, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: _orange,
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                job.title,
                style: const TextStyle(
                  color: _slate,
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _jobPill(
                    Icons.cleaning_services_outlined,
                    job.category,
                    _primary,
                  ),
                  _jobPill(Icons.location_on_outlined, job.district, _navy),
                  if (job.duration.trim().isNotEmpty)
                    _jobPill(Icons.schedule_outlined, job.duration, _purple),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                job.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F9FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: _green,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Open job • Apply from job details',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(
                      'Read Job',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: _primary,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobPill(IconData icon, String text, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobsEmptyState extends StatelessWidget {
  const _JobsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_off_outlined,
                color: _primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No jobs found',
              style: TextStyle(
                color: _slate,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another district, service, or search word.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts =
      name
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

  if (parts.isEmpty) {
    return 'H';
  }

  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
