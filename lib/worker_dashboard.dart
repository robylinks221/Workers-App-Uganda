import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/api_config.dart';
import 'models/worker_dashboard_data.dart';
import 'services/worker_dashboard_service.dart';

import './features/tips/dashboard_smart_tips.dart';

const _primary = Color(0xFFD87C53);
const _slate = Color(0xFF395264);
const _slateLight = Color(0xFF4F7089);
const _subText = Color(0xFF5C7A8C);
const _muted = Color(0xFFB0A098);
const _border = Color(0xFFEAE0D8);
const _background = Color(0xFFF8F5F3);
const _green = Color(0xFF27AE60);
const _amber = Color(0xFFF39C12);

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final WorkerDashboardService _service = WorkerDashboardService();

  WorkerDashboardData? _data;
  String? _error;
  bool _loading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getDashboard();

    if (!mounted) return;

    if (result['success'] == true) {
      try {
        setState(() {
          _data = WorkerDashboardData.fromJson(result);
          _loading = false;
        });
      } catch (error) {
        setState(() {
          _error = 'Unable to read dashboard data: $error';
          _loading = false;
        });
      }
      return;
    }

    setState(() {
      _error = result['message']?.toString() ?? 'Unable to load dashboard.';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    if (_loading) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_error != null || _data == null) {
      return Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: _primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dashboard unavailable',
                    style: TextStyle(
                      color: _slate,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _error ?? 'Unknown error.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _subText, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _loadDashboard,
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

    return Scaffold(
      backgroundColor: _background,
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _DashboardHeader(data: data)),
            SliverToBoxAdapter(child: _StatsCard(data: data)),
            SliverToBoxAdapter(child: _EarningsCard(data: data)),
            const SliverToBoxAdapter(
              child: DashboardSmartTipsCard(
                audience: TipAudience.worker,
                margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionTitle(title: 'Pending Applications'),
            ),
            if (data.pendingApplications.isEmpty)
              const SliverToBoxAdapter(
                child: _EmptyCard(
                  icon: Icons.assignment_outlined,
                  title: 'No pending applications',
                  subtitle: 'Applications you send for jobs will appear here.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: data.pendingApplications.length,
                  itemBuilder:
                      (_, index) => _ApplicationCard(
                        application: data.pendingApplications[index],
                      ),
                ),
              ),
            const SliverToBoxAdapter(
              child: _SectionTitle(title: 'Active Jobs'),
            ),
            if (data.activeJobs.isEmpty)
              const SliverToBoxAdapter(
                child: _EmptyCard(
                  icon: Icons.work_off_rounded,
                  title: 'No active jobs yet',
                  subtitle: 'Accepted and ongoing jobs will appear here.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: data.activeJobs.length,
                  itemBuilder:
                      (_, index) => _JobCard(job: data.activeJobs[index]),
                ),
              ),
            const SliverToBoxAdapter(
              child: _SectionTitle(title: 'Recent Activity'),
            ),
            if (data.recentActivity.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 110),
                  child: _EmptyCard(
                    icon: Icons.history_rounded,
                    title: 'No recent activity',
                    subtitle:
                        'Payments, reviews and completed jobs appear here.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverList.builder(
                  itemCount: data.recentActivity.length,
                  itemBuilder:
                      (_, index) =>
                          _ActivityCard(item: data.recentActivity[index]),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) => setState(() => _navIndex = index),
        indicatorColor: const Color(0xFFFAEEE6),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            label: 'My Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.data});

  final WorkerDashboardData data;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.storageUrl(data.user.profilePhoto);
    final firstName =
        data.user.fullName.trim().isEmpty
            ? 'Worker'
            : data.user.fullName.trim().split(RegExp(r'\s+')).first;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_slateLight, Color(0xFF2A3D4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _slateLight,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty
                          ? Text(
                            _initials(data.user.fullName),
                            style: const TextStyle(
                              color: Colors.white,
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
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        firstName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        data.profile.district,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: _green),
                  const SizedBox(width: 10),
                  const Text(
                    'Availability',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    _titleCase(data.profile.availability),
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w800,
                    ),
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

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.data});

  final WorkerDashboardData data;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Jobs Done', '${data.statistics.jobsCompleted}', Icons.work_rounded),
      ('Rating', data.statistics.rating.toStringAsFixed(1), Icons.star_rounded),
      ('Reviews', '${data.statistics.totalReviews}', Icons.reviews_rounded),
      ('Active', '${data.statistics.activeJobs}', Icons.flash_on_rounded),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: _cardDecoration(),
      child: Row(
        children:
            stats
                .map(
                  (item) => Expanded(
                    child: Column(
                      children: [
                        Icon(item.$3, color: _primary),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: _slate,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          item.$1,
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.data});

  final WorkerDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, Color(0xFFC0622E)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Month',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.earnings.currency} ${_money(data.earnings.thisMonth)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${data.earnings.currency} ${_money(data.earnings.total)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.statistics.activeJobs} Active',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pending payout',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              Text(
                '${data.earnings.currency} ${_money(data.earnings.pending)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: _slate,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _slate,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _subText, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});
  final Map<String, dynamic> application;

  @override
  Widget build(BuildContext context) {
    final job = _map(application['job']);
    return _SimpleCard(
      title: _text(job['title'], fallback: 'Job application'),
      subtitle: _text(job['district']),
      badge: _text(application['status'], fallback: 'pending'),
      badgeColor: _amber,
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    return _SimpleCard(
      title: _text(job['title'], fallback: 'Active job'),
      subtitle: _text(job['district']),
      badge: _text(job['status'], fallback: 'active'),
      badgeColor: _green,
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _slate,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: _subText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              _titleCase(badge),
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.notifications_rounded, color: _primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(item['title'], fallback: 'Activity'),
                  style: const TextStyle(
                    color: _slate,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _text(item['subtitle']),
                  style: const TextStyle(color: _subText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: _border),
  );
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String _money(double value) {
  final digits = value.round().toString();
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

String _titleCase(String value) {
  return value
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
