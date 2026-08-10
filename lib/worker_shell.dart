import 'package:flutter/material.dart';

import 'conversations_screen.dart';
import 'features/hiring/worker_hiring_requests_screen.dart';
import 'features/profile/account_screen.dart';
import 'services/notification_badge_service.dart';
import 'services/worker_profile_service.dart';
import 'widgets/premium_floating_nav_bar.dart';
import 'worker_home.dart';

const _shellPrimary = Color(0xFF1FB8B3);

class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  final WorkerProfileService _profileService = WorkerProfileService();
  final NotificationBadgeService _badges = NotificationBadgeService.instance;

  int _currentIndex = 0;
  Map<String, dynamic> _user = const {};
  Map<String, dynamic> _profile = const {};
  bool _loadingAccount = true;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
    _badges.startForRole('worker');
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

    if (index == 1) {
      _badges.clearRequestBadge();
    } else if (index == 2) {
      _badges.clearMessageBadge();
    }

    _badges.refresh();
  }

  Future<void> _openApplications() async {
    _selectTab(1);
  }

  @override
  void dispose() {
    _badges.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      WorkerHomeScreen(
        onOpenAccount: () => _selectTab(3),
        onOpenApplications: _openApplications,
      ),
      const WorkerHiringRequestsScreen(),
      const ConversationsScreen(),
      _loadingAccount
          ? const Center(child: CircularProgressIndicator(color: _shellPrimary))
          : AccountScreen(
            role: 'worker',
            user: _user,
            profile: _profile,
            onBack: () => _selectTab(0),
          ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              PremiumFloatingNavItem(
                label: 'Requests',
                icon: Icons.mark_email_unread_outlined,
                badgeCount: _badges.pendingHiringRequests,
                badgeColor: const Color(0xFFE53935),
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
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
