import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/worker_marketplace_service.dart';
import '../profile/worker_public_profile_screen.dart';
import '../worker/widgets/worker_filter_options.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _surfaceBg = Color(0xFFF4F7FA);

class BrowseWorkersScreen extends StatefulWidget {
  const BrowseWorkersScreen({super.key, this.initialServiceSlug = ''});

  final String initialServiceSlug;

  @override
  State<BrowseWorkersScreen> createState() => _BrowseWorkersScreenState();
}

class _BrowseWorkersScreenState extends State<BrowseWorkersScreen> {
  final WorkerMarketplaceService _service = WorkerMarketplaceService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _districtFilterController =
      TextEditingController();

  Timer? _searchTimer;

  List<Map<String, dynamic>> _workers = const [];
  List<Map<String, dynamic>> _categories = const [];

  String _serviceSlug = '';
  String _serviceName = '';
  String _district = '';
  String _gender = '';
  String _religion = '';
  RangeValues _ageRange = const RangeValues(18, 70);

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  int _page = 1;
  bool _hasMore = false;
  int _total = 0;

  static const _religions = [
    'Christian',
    'Muslim',
    'Catholic',
    'Seventh-Day Adventist',
    'Other / Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _serviceSlug = widget.initialServiceSlug.trim();
    _loadScreen();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _districtFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadScreen() async {
    await _loadCategories();
    await _loadWorkers();
  }

  Future<void> _loadCategories() async {
    final result = await _service.getCategories();

    if (!mounted) return;

    final categories = <Map<String, dynamic>>[];

    if (result['success'] == true && result['service_categories'] is List) {
      for (final raw in result['service_categories'] as List) {
        if (raw is Map) {
          categories.add(Map<String, dynamic>.from(raw));
        }
      }
    }

    String validSlug = '';
    String validName = '';

    if (_serviceSlug.isNotEmpty) {
      for (final category in categories) {
        if (category['slug']?.toString() == _serviceSlug) {
          validSlug = _serviceSlug;
          validName = category['name']?.toString() ?? '';
          break;
        }
      }
    }

    setState(() {
      _categories = categories;
      _serviceSlug = validSlug;
      _serviceName = validName;
    });
  }

  Future<void> _loadWorkers({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final requestedPage = reset ? 1 : _page + 1;

    final result = await _service.getWorkers(
      search: _searchController.text.trim(),
      service: _serviceSlug,
      district: _district,
      gender: _gender,
      religion: _religion,
      minAge: _ageRange.start.round(),
      maxAge: _ageRange.end.round(),
      sort: 'rating',
      page: requestedPage,
      perPage: 20,
    );

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _error = result['message']?.toString() ?? 'Unable to load workers.';
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    final incoming = <Map<String, dynamic>>[];

    if (result['workers'] is List) {
      for (final raw in result['workers'] as List) {
        if (raw is Map) {
          incoming.add(Map<String, dynamic>.from(raw));
        }
      }
    }

    final pagination =
        result['pagination'] is Map
            ? Map<String, dynamic>.from(result['pagination'])
            : <String, dynamic>{};

    setState(() {
      _workers = reset ? incoming : [..._workers, ...incoming];

      _page =
          int.tryParse(pagination['current_page']?.toString() ?? '') ??
          requestedPage;

      _hasMore = pagination['has_more_pages'] == true;

      _total =
          int.tryParse(pagination['total']?.toString() ?? '') ??
          _workers.length;

      _loading = false;
      _loadingMore = false;
      _error = null;
    });
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) {
        _loadWorkers();
      }
    });

    setState(() {});
  }

  int get _filterCount {
    var count = 0;

    if (_district.isNotEmpty) count++;
    if (_gender.isNotEmpty) count++;
    if (_religion.isNotEmpty) count++;
    if (_serviceSlug.isNotEmpty) count++;

    if (_ageRange.start > 18 || _ageRange.end < 70) {
      count++;
    }

    return count;
  }

  Future<void> _openFilters() async {
    String draftDistrict = _district;
    String draftGender = _gender;
    String draftReligion = _religion;
    String draftServiceSlug = _serviceSlug;
    String draftServiceName = _serviceName;
    RangeValues draftAge = _ageRange;
    String districtQuery = _district;

    _districtFilterController.value = TextEditingValue(
      text: _district,
      selection: TextSelection.collapsed(offset: _district.length),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final districtMatches =
                districtQuery.trim().isEmpty
                    ? const <String>[]
                    : ugandaJobLocations
                        .where(
                          (district) => district.toLowerCase().contains(
                            districtQuery.trim().toLowerCase(),
                          ),
                        )
                        .take(7)
                        .toList();

            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.90,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
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
                      const _ModernSectionHeading(
                        eyebrow: 'FIND THE RIGHT PERSON',
                        title: 'Choose What You Need',
                        subtitle:
                            'Use only the filters that matter to you. You can leave the others empty.',
                      ),
                      const SizedBox(height: 22),

                      const _FilterHeading(
                        icon: Icons.auto_awesome_outlined,
                        title: 'What Help Do You Need?',
                        subtitle:
                            'Choose a skill or service, such as cleaning, cooking or child care.',
                      ),
                      const SizedBox(height: 9),

                      PopupMenuButton<Map<String, dynamic>>(
                        onSelected: (category) {
                          setSheetState(() {
                            draftServiceSlug =
                                category['slug']?.toString() ?? '';
                            draftServiceName =
                                category['name']?.toString() ?? '';
                          });
                        },
                        elevation: 12,
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        constraints: const BoxConstraints(
                          minWidth: 290,
                          maxWidth: 360,
                          maxHeight: 420,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        itemBuilder:
                            (_) =>
                                _categories.map((category) {
                                  final slug =
                                      category['slug']?.toString() ?? '';
                                  final selected = slug == draftServiceSlug;

                                  return PopupMenuItem<Map<String, dynamic>>(
                                    value: category,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color:
                                                selected
                                                    ? _primary.withValues(
                                                      alpha: 0.12,
                                                    )
                                                    : const Color(0xFFF4F8FA),
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.cleaning_services_outlined,
                                            color: selected ? _primary : _muted,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            category['name']?.toString() ??
                                                'Skill / Service',
                                            style: TextStyle(
                                              color:
                                                  selected ? _primary : _slate,
                                              fontWeight:
                                                  selected
                                                      ? FontWeight.w900
                                                      : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (selected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: _primary,
                                            size: 19,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F9FA),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
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
                                  draftServiceName.isEmpty
                                      ? 'Any skill or service'
                                      : draftServiceName,
                                  style: TextStyle(
                                    color:
                                        draftServiceName.isEmpty
                                            ? _muted
                                            : _slate,
                                    fontWeight:
                                        draftServiceName.isEmpty
                                            ? FontWeight.w600
                                            : FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (draftServiceSlug.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      draftServiceSlug = '';
                                      draftServiceName = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: _muted,
                                    size: 18,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: _primary,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const _FilterHeading(
                        icon: Icons.location_on_outlined,
                        title: 'Where Should the Worker Be From?',
                        subtitle:
                            'Start typing a district name, for example Kam for Kampala.',
                      ),
                      const SizedBox(height: 9),

                      TextField(
                        controller: _districtFilterController,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          setSheetState(() {
                            districtQuery = value;
                            draftDistrict = value;
                          });
                        },
                        decoration: _modernInputDecoration(
                          'Start typing district',
                          Icons.search_rounded,
                        ).copyWith(
                          suffixIcon:
                              districtQuery.trim().isEmpty
                                  ? null
                                  : IconButton(
                                    tooltip: 'Clear district',
                                    onPressed: () {
                                      _districtFilterController.clear();
                                      setSheetState(() {
                                        districtQuery = '';
                                        draftDistrict = '';
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: _muted,
                                    ),
                                  ),
                        ),
                      ),

                      if (districtMatches.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F9FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children:
                                districtMatches.map((district) {
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();

                                        _districtFilterController
                                            .value = TextEditingValue(
                                          text: district,
                                          selection: TextSelection.collapsed(
                                            offset: district.length,
                                          ),
                                        );

                                        setSheetState(() {
                                          draftDistrict = district;
                                          districtQuery = '';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              color: _primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                district,
                                                style: const TextStyle(
                                                  color: _slate,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              color: _primary,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      const _FilterHeading(
                        icon: Icons.wc_outlined,
                        title: 'Sex',
                        subtitle: 'Choose only if this matters to you.',
                      ),
                      const SizedBox(height: 9),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChoiceChip(
                            label: 'Any',
                            selected: draftGender.isEmpty,
                            onTap: () {
                              setSheetState(() {
                                draftGender = '';
                              });
                            },
                          ),
                          _FilterChoiceChip(
                            label: 'Female',
                            selected: draftGender == 'female',
                            onTap: () {
                              setSheetState(() {
                                draftGender = 'female';
                              });
                            },
                          ),
                          _FilterChoiceChip(
                            label: 'Male',
                            selected: draftGender == 'male',
                            onTap: () {
                              setSheetState(() {
                                draftGender = 'male';
                              });
                            },
                          ),
                          _FilterChoiceChip(
                            label: 'Other',
                            selected: draftGender == 'other',
                            onTap: () {
                              setSheetState(() {
                                draftGender = 'other';
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const _FilterHeading(
                        icon: Icons.cake_outlined,
                        title: 'Preferred Age',
                        subtitle: 'Move the two points to choose an age range.',
                      ),
                      const SizedBox(height: 9),

                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F9FA),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${draftAge.start.round()} years',
                                  style: const TextStyle(
                                    color: _slate,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${draftAge.end.round()} years',
                                  style: const TextStyle(
                                    color: _slate,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            RangeSlider(
                              min: 18,
                              max: 70,
                              divisions: 52,
                              activeColor: _primary,
                              values: draftAge,
                              onChanged: (value) {
                                setSheetState(() {
                                  draftAge = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const _FilterHeading(
                        icon: Icons.favorite_border_rounded,
                        title: 'Religion (Optional)',
                        subtitle:
                            'Leave this as Any religion if it does not matter.',
                      ),
                      const SizedBox(height: 9),

                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setSheetState(() {
                            draftReligion = value;
                          });
                        },
                        elevation: 12,
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        itemBuilder:
                            (_) => [
                              const PopupMenuItem(
                                value: '',
                                child: Text('Any religion'),
                              ),
                              ..._religions.map(
                                (religion) => PopupMenuItem(
                                  value: religion,
                                  child: Text(religion),
                                ),
                              ),
                            ],
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F9FA),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite_border_rounded,
                                color: _primary,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  draftReligion.isEmpty
                                      ? 'Any religion'
                                      : draftReligion,
                                  style: const TextStyle(
                                    color: _slate,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _districtFilterController.clear();

                                setSheetState(() {
                                  draftDistrict = '';
                                  districtQuery = '';
                                  draftGender = '';
                                  draftReligion = '';
                                  draftAge = const RangeValues(18, 70);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _navy,
                                minimumSize: const Size.fromHeight(52),
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
                                  _district = draftDistrict.trim();
                                  _gender = draftGender;
                                  _religion = draftReligion;
                                  _serviceSlug = draftServiceSlug;
                                  _serviceName = draftServiceName;
                                  _ageRange = draftAge;
                                });

                                Navigator.pop(sheetContext);

                                _loadWorkers();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.tune_rounded),
                              label: const Text(
                                'Show Workers',
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
            );
          },
        );
      },
    );
  }

  Future<void> _changeService(String slug) async {
    var name = '';

    for (final category in _categories) {
      if (category['slug']?.toString() == slug) {
        name = category['name']?.toString() ?? '';
        break;
      }
    }

    setState(() {
      _serviceSlug = slug;
      _serviceName = name;
    });

    await _loadWorkers();
  }

  Future<void> _toggleSaved(Map<String, dynamic> worker) async {
    final workerId = int.tryParse(worker['id']?.toString() ?? '');

    if (workerId == null || workerId <= 0 || worker['saving'] == true) {
      return;
    }

    final saved = worker['is_saved'] == true;

    setState(() {
      worker['saving'] = true;
    });

    final result =
        saved
            ? await _service.removeSavedWorker(workerId)
            : await _service.saveWorker(workerId);

    if (!mounted) return;

    setState(() {
      worker['saving'] = false;

      if (result['success'] == true) {
        worker['is_saved'] = result['is_saved'] == true;
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Saved worker request completed.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              result['success'] == true ? _navy : Colors.red.shade700,
        ),
      );
  }

  void _openWorker(Map<String, dynamic> worker) {
    final workerId = int.tryParse(worker['id']?.toString() ?? '');

    if (workerId == null || workerId <= 0) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerPublicProfileScreen(workerId: workerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      elevation: 6,
                      shadowColor: _navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search worker by name or district',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _primary,
                          ),
                          suffixIcon:
                              _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                      _loadWorkers();
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
                    isLabelVisible: _filterCount > 0,
                    label: Text(_filterCount.toString()),
                    child: Material(
                      color: Colors.white,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: _openFilters,
                        borderRadius: BorderRadius.circular(18),
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
            ),
            if (_categories.isNotEmpty)
              SizedBox(
                height: 49,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return ChoiceChip(
                        label: const Text('All Skills'),
                        selected: _serviceSlug.isEmpty,
                        onSelected: (_) => _changeService(''),
                      );
                    }

                    final category = _categories[index - 1];

                    final slug = category['slug']?.toString() ?? '';

                    return ChoiceChip(
                      avatar: const Icon(
                        Icons.cleaning_services_outlined,
                        size: 16,
                      ),
                      label: Text(
                        category['name']?.toString() ?? 'Skill / Service',
                      ),
                      selected: slug == _serviceSlug,
                      onSelected: (_) => _changeService(slug),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C2D4B), _navy, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FIND A WORKER',
                  style: TextStyle(
                    color: Color(0xFFC7E3E7),
                    fontSize: 9.5,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Find Help for Your Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _serviceName.isEmpty
                      ? 'Search approved workers, then open a profile to learn more.'
                      : 'Showing workers offering $_serviceName.',
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '$_total',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Could Not Load Workers',
        message: _error!,
        buttonLabel: 'Try Again',
        onPressed: _loadWorkers,
      );
    }

    if (_workers.isEmpty) {
      return _MessageState(
        icon: Icons.person_search_outlined,
        title: 'No Workers Match Your Search',
        message: 'Try removing one or two filters to see more workers.',
        buttonLabel: 'Clear Search',
        onPressed: () {
          setState(() {
            _district = '';
            _gender = '';
            _religion = '';
            _ageRange = const RangeValues(18, 70);
          });

          _loadWorkers();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkers,
      color: _primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: _workers.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 13),
        itemBuilder: (_, index) {
          if (index == _workers.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child:
                    _loadingMore
                        ? const CircularProgressIndicator(color: _primary)
                        : OutlinedButton(
                          onPressed: () => _loadWorkers(reset: false),
                          child: const Text('Load More'),
                        ),
              ),
            );
          }

          return _WorkerCard(
            worker: _workers[index],
            onOpen: () => _openWorker(_workers[index]),
            onSave: () => _toggleSaved(_workers[index]),
          );
        },
      ),
    );
  }
}

class _ModernSectionHeading extends StatelessWidget {
  const _ModernSectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _primary,
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: _slate,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _FilterHeading extends StatelessWidget {
  const _FilterHeading({
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
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  const _FilterChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _primary,
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: selected ? Colors.white : _slate,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

InputDecoration _modernInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: _primary),
    filled: true,
    fillColor: const Color(0xFFF6F9FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide.none,
    ),
  );
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({
    required this.worker,
    required this.onOpen,
    required this.onSave,
  });

  final Map<String, dynamic> worker;
  final VoidCallback onOpen;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final rawName = worker['full_name']?.toString().trim() ?? '';
    final name = rawName.isEmpty ? 'Worker' : rawName;

    final imageUrl = ApiConfig.storageUrl(worker['profile_photo']?.toString());

    final district =
        worker['district']?.toString().trim().isNotEmpty == true
            ? worker['district'].toString()
            : worker['location']?.toString() ?? 'Location not provided';

    final saved = worker['is_saved'] == true;
    final saving = worker['saving'] == true;
    final services = _serviceNames(worker);

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
                      backgroundColor: _primary.withValues(alpha: 0.12),
                      backgroundImage:
                          imageUrl.isEmpty ? null : NetworkImage(imageUrl),
                      child:
                          imageUrl.isEmpty
                              ? Text(
                                _initials(name),
                                style: const TextStyle(
                                  color: _primary,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        const SizedBox(height: 6),
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                district,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
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
                              color: saved ? const Color(0xFFE94877) : _primary,
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
                        services.take(3).map((service) {
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
              SizedBox(
                width: double.infinity,
                height: 47,
                child: FilledButton.icon(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('See Worker'),
                ),
              ),
            ],
          ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _primary, size: 64),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w900,
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

List<String> _serviceNames(Map<String, dynamic> worker) {
  final raw = worker['services'];

  if (raw is! List) return const [];

  return raw
      .map((item) {
        final value = _map(item);
        return value['name']?.toString() ?? '';
      })
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
