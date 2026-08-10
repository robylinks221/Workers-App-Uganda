import 'package:flutter/material.dart';

import 'features/homeowner/widgets/dashboard_header.dart';
import 'features/homeowner/widgets/new_workers_carousel.dart';
import 'features/homeowner/widgets/quick_links.dart';
import 'features/homeowner/widgets/recommended_workers.dart';
import 'features/homeowner/widgets/services_section.dart';
import 'features/homeowner/widgets/work_wanted_preview.dart';
import 'features/profile/worker_public_profile_screen.dart';
import 'features/work_wanted/homeowner_work_wanted_screen.dart';
import 'post_job.dart';
import 'saved_workers_screen.dart';
import 'services/homeowner_profile_service.dart';
import 'services/logout_helper.dart';
import 'services/worker_marketplace_service.dart';
import 'services/work_wanted_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class HomeownerHomeScreen extends StatefulWidget {
  const HomeownerHomeScreen({
    super.key,
    required this.onBrowseWorkers,
    required this.onMyJobs,
    required this.onMessages,
  });

  final ValueChanged<String> onBrowseWorkers;
  final VoidCallback onMyJobs;
  final VoidCallback onMessages;

  @override
  State<HomeownerHomeScreen> createState() => _HomeownerHomeScreenState();
}

class _HomeownerHomeScreenState extends State<HomeownerHomeScreen> {
  final HomeownerProfileService _profileService = HomeownerProfileService();
  final WorkerMarketplaceService _marketplaceService =
      WorkerMarketplaceService();
  final WorkWantedService _workWantedService = WorkWantedService();

  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _recommendedWorkers = const [];
  List<Map<String, dynamic>> _newWorkers = const [];
  List<Map<String, dynamic>> _serviceCategories = const [];
  List<Map<String, dynamic>> _workWantedPosts = const [];

  String? _error;
  bool _loading = true;
  bool _loadingWorkers = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _loadingWorkers = true;
      _error = null;
    });

    final results = await Future.wait([
      _profileService.getProfile(),
      _marketplaceService.getWorkers(
        availability: 'available',
        sort: 'rating',
        perPage: 6,
      ),
      _marketplaceService.getWorkers(sort: 'newest', perPage: 10),
      _marketplaceService.getCategories(),
      _workWantedService.browse(),
    ]);

    if (!mounted) return;

    final profileResult = results[0];
    final workersResult = results[1];
    final newestWorkersResult = results[2];
    final categoriesResult = results[3];
    final workWantedResult = results[4];

    if (profileResult['success'] != true) {
      setState(() {
        _error =
            profileResult['message']?.toString() ??
            'Unable to load your dashboard.';
        _loading = false;
        _loadingWorkers = false;
      });
      return;
    }

    final workers = <Map<String, dynamic>>[];
    final rawWorkers = workersResult['workers'];

    if (workersResult['success'] == true && rawWorkers is List) {
      for (final worker in rawWorkers) {
        workers.add(_map(worker));
      }
    }

    final newestWorkers = <Map<String, dynamic>>[];
    final rawNewestWorkers = newestWorkersResult['workers'];

    if (newestWorkersResult['success'] == true && rawNewestWorkers is List) {
      for (final worker in rawNewestWorkers) {
        newestWorkers.add(_map(worker));
      }
    }

    final categories = <Map<String, dynamic>>[];
    final rawCategories = categoriesResult['service_categories'];

    if (categoriesResult['success'] == true && rawCategories is List) {
      for (final category in rawCategories) {
        categories.add(_map(category));
      }
    }

    final workWantedPosts = <Map<String, dynamic>>[];
    final rawWorkWanted = workWantedResult['posts'];
    if (workWantedResult['success'] == true && rawWorkWanted is List) {
      for (final post in rawWorkWanted) {
        if (post is Map) workWantedPosts.add(Map<String, dynamic>.from(post));
      }
    }

    setState(() {
      _profileData = profileResult;
      _recommendedWorkers = workers;
      _newWorkers = newestWorkers;
      _serviceCategories = categories.take(6).toList();
      _workWantedPosts = workWantedPosts;
      _loading = false;
      _loadingWorkers = false;
    });
  }

  Future<void> _openBrowse({String service = ''}) async {
    widget.onBrowseWorkers(service);
  }

  Future<void> _openJobs() async {
    widget.onMyJobs();
  }

  Future<void> _openPostJob() async {
    final posted = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PostJobScreen()));

    if (posted == true && mounted) {
      await _loadDashboard();
    }
  }

  Future<void> _openSavedWorkers() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SavedWorkersScreen()));

    if (mounted) {
      await _loadDashboard();
    }
  }

  void _openWorkerProfile(Map<String, dynamic> worker) {
    final id = int.tryParse(worker['id']?.toString() ?? '');

    if (id == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerPublicProfileScreen(workerId: id),
      ),
    );
  }

  Future<void> _toggleSaved(Map<String, dynamic> worker) async {
    final workerId = int.tryParse(worker['id']?.toString() ?? '');

    if (workerId == null) return;

    final isSaved = worker['is_saved'] == true;
    setState(() => worker['saving'] = true);

    final result =
        isSaved
            ? await _marketplaceService.removeSavedWorker(workerId)
            : await _marketplaceService.saveWorker(workerId);

    if (!mounted) return;

    setState(() {
      worker['saving'] = false;

      if (result['success'] == true) {
        worker['is_saved'] = result['is_saved'] == true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const _DashboardLoading(),
      );
    }

    if (_error != null || _profileData == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _ErrorView(
          message: _error ?? 'Unable to load your dashboard.',
          onRetry: _loadDashboard,
        ),
      );
    }

    final user = _map(_profileData!['user']);
    final profile = _map(_profileData!['profile']);

    final fullName = user['full_name']?.toString() ?? 'Homeowner';
    final firstName =
        fullName.trim().isEmpty
            ? 'Homeowner'
            : fullName.trim().split(RegExp(r'\s+')).first;

    final imageUrl = user['profile_photo']?.toString() ?? '';
    final location =
        profile['district']?.toString() ?? user['location']?.toString() ?? '';

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: RefreshIndicator(
        color: _primary,
        onRefresh: _loadDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DashboardHeader(
                fullName: fullName,
                firstName: firstName,
                location: location,
                imagePath: imageUrl,
                onSearch: _openBrowse,
                onLogout: () => LogoutHelper.confirmAndLogout(context),
              ),
            ),
            SliverToBoxAdapter(
              child: QuickLinks(
                onBrowseWorkers: _openBrowse,
                onPostJob: _openPostJob,
                onMyJobs: _openJobs,
                onSavedWorkers: _openSavedWorkers,
              ),
            ),
            SliverToBoxAdapter(
              child: ServicesSection(
                categories: _serviceCategories,
                onViewAll: _openBrowse,
                onSelectService: (slug) => _openBrowse(service: slug),
              ),
            ),
            SliverToBoxAdapter(
              child: WorkWantedPreview(
                posts: _workWantedPosts,
                onViewAll:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HomeownerWorkWantedScreen(),
                      ),
                    ),
                onOpenWorker: (post) {
                  final worker =
                      post['worker'] is Map
                          ? Map<String, dynamic>.from(post['worker'])
                          : <String, dynamic>{};
                  _openWorkerProfile(worker);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: NewWorkersCarousel(
                workers: _newWorkers,
                onViewAll: _openBrowse,
                onOpenWorker: _openWorkerProfile,
                onToggleSaved: _toggleSaved,
              ),
            ),
            SliverToBoxAdapter(
              child: RecommendedWorkers(
                workers: _recommendedWorkers,
                loading: _loadingWorkers,
                onViewAll: _openBrowse,
                onOpenWorker: _openWorkerProfile,
                onToggleSaved: _toggleSaved,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          4,
          (_) => Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: _primary, size: 62),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
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

class _WorkWantedHomeCard extends StatelessWidget {
  const _WorkWantedHomeCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17324D),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF24445F),
            child: Icon(Icons.person_search_rounded, color: Colors.white),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workers Looking for Work',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'See active worker posts and send the right person a job offer.',
                  style: TextStyle(
                    color: Color(0xFFD5E1E8),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
        ],
      ),
    ),
  );
}
