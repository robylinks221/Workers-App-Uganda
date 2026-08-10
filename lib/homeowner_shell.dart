import 'package:flutter/material.dart';

import 'conversations_screen.dart';
import 'features/marketplace/browse_workers_screen.dart';
import 'features/profile/account_screen.dart';
import 'homeowner_home.dart';
import 'features/homeowner/homeowner_jobs_hub_screen.dart';
import 'services/homeowner_profile_service.dart';
import 'services/notification_badge_service.dart';
import 'widgets/premium_floating_nav_bar.dart';

const _shellPrimary = Color(0xFF1FB8B3);

class HomeownerShell extends StatefulWidget {
  const HomeownerShell({super.key});

  @override
  State<HomeownerShell> createState() => _HomeownerShellState();
}

class _HomeownerShellState extends State<HomeownerShell> {
  final HomeownerProfileService _profileService = HomeownerProfileService();
  final NotificationBadgeService _badges = NotificationBadgeService.instance;

  int _currentIndex = 0;
  Map<String, dynamic> _user = const {};
  Map<String, dynamic> _profile = const {};
  bool _loadingAccount = true;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
    _badges.startForRole('homeowner');
  }

  Future<void> _loadAccountData() async {
    final result = await _profileService.getProfile();

    if (!mounted) return;

    setState(() {
      _user = _map(result['user']);
      _profile = _map(result['profile']);
      _loadingAccount = false;
    });
  }

  void _selectTab(int index) {
    if (!mounted || index == _currentIndex) return;

    setState(() => _currentIndex = index);

    if (index == 2) {
      _badges.clearMessageBadge();
    }

    _badges.refresh();
  }

  Future<void> _openBrowseWorkers(String serviceSlug) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrowseWorkersScreen(initialServiceSlug: serviceSlug),
      ),
    );

    _badges.refresh();
  }

  @override
  void dispose() {
    _badges.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeownerHomeScreen(
        onBrowseWorkers: _openBrowseWorkers,
        onMyJobs: () => _selectTab(1),
        onMessages: () => _selectTab(2),
      ),
      const HomeownerJobsHubScreen(),
      const ConversationsScreen(),
      _loadingAccount
          ? const Center(child: CircularProgressIndicator(color: _shellPrimary))
          : AccountScreen(
            role: 'homeowner',
            user: _user,
            profile: _profile,
            onBack: () => _selectTab(0),
          ),
    ];

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AnimatedBuilder(
        animation: _badges,
        builder: (context, _) {
          return PremiumFloatingNavBar(
            currentIndex: _currentIndex,
            onTap: _selectTab,
            items: [
              const PremiumFloatingNavItem(
                label: 'Home',
                icon: Icons.home_outlined,
              ),
              const PremiumFloatingNavItem(
                label: 'Jobs',
                icon: Icons.work_outline_rounded,
              ),
              PremiumFloatingNavItem(
                label: 'Messages',
                icon: Icons.chat_bubble_outline_rounded,
                badgeCount: _badges.unreadMessages,
                badgeColor: const Color(0xFFE53935),
              ),
              const PremiumFloatingNavItem(
                label: 'Account',
                icon: Icons.person_outline_rounded,
              ),
            ],
          );
        },
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}
