import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/services/auth_service.dart';
import '../../services/admin_service.dart';
import 'admin_account_appeals_screen.dart';
import 'admin_users_screen.dart';
import 'admin_worker_verifications_screen.dart';

const _teal = Color(0xFF20B9B4);
const _navy = Color(0xFF123F67);
const _deepNavy = Color(0xFF0C2D4B);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);
const _surface = Color(0xFFF4F7FA);
const _orange = Color(0xFFF28C45);
const _red = Color(0xFFE45B63);
const _green = Color(0xFF27A56A);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _service = AdminService();
  final AuthService _auth = AuthService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _stats = <String, dynamic>{};
  Map<String, dynamic> _admin = <String, dynamic>{};

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

    final result = await _service.dashboard();

    if (!mounted) return;

    setState(() {
      _loading = false;

      if (result['success'] == true) {
        _stats = Map<String, dynamic>.from(
          result['stats'] ?? <String, dynamic>{},
        );
        _admin = Map<String, dynamic>.from(
          result['admin'] ?? <String, dynamic>{},
        );
      } else {
        _error =
            result['message']?.toString() ??
            'Unable to load the admin dashboard.';
      }
    });
  }

  Future<void> _logout() async {
    await _auth.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _surface,
        body: RefreshIndicator(
          onRefresh: _load,
          color: _teal,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _heroHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(color: _teal),
                        ),
                      )
                    else if (_error != null)
                      _errorCard()
                    else ...[
                      _sectionTitle(
                        eyebrow: 'LIVE PLATFORM',
                        title: 'Platform Overview',
                        subtitle:
                            'A quick view of marketplace activity and items that need attention.',
                      ),
                      const SizedBox(height: 16),
                      _attentionStrip(),
                      const SizedBox(height: 18),
                      _overviewGrid(),
                      const SizedBox(height: 30),
                      _sectionTitle(
                        eyebrow: 'ADMIN TOOLS',
                        title: 'Quick Actions',
                        subtitle:
                            'Review verification, account safety and marketplace users.',
                      ),
                      const SizedBox(height: 16),
                      _quickActions(),
                      const SizedBox(height: 30),
                      _sectionTitle(
                        eyebrow: 'WORKER TRUST',
                        title: 'Verification Health',
                        subtitle:
                            'Current approval and rejection status across worker profiles.',
                      ),
                      const SizedBox(height: 14),
                      _verificationHealth(),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroHeader() {
    final name =
        _admin['full_name']?.toString().trim().isNotEmpty == true
            ? _admin['full_name'].toString().trim()
            : 'Administrator';

    final firstName = name.split(' ').first;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        16,
        30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B2A47), Color(0xFF124C6A), Color(0xFF1AA5A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.055),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 68,
            bottom: -72,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WORKLINK AFRICA',
                          style: TextStyle(
                            color: Color(0xFFBBD7E6),
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Admin Control Center',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh',
                    onTap: _load,
                  ),
                  const SizedBox(width: 7),
                  _HeaderButton(
                    icon: Icons.logout_rounded,
                    tooltip: 'Logout',
                    onTap: _logout,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Good to see you, $firstName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Manage trust, safety and marketplace activity from one place.',
                style: TextStyle(
                  color: Color(0xFFD7E7ED),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _teal,
            fontSize: 10.5,
            letterSpacing: 1.55,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: _slate,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: _muted, fontSize: 12.5, height: 1.45),
        ),
      ],
    );
  }

  Widget _attentionStrip() {
    final verifications = _n('pending_verifications');
    final appeals = _n('pending_appeals');

    return Row(
      children: [
        Expanded(
          child: _AttentionCard(
            label: 'Verification',
            value: verifications,
            caption:
                verifications == 1 ? 'profile waiting' : 'profiles waiting',
            icon: Icons.fact_check_outlined,
            accent: _orange,
            onTap: _openVerifications,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _AttentionCard(
            label: 'Appeals',
            value: appeals,
            caption: appeals == 1 ? 'appeal waiting' : 'appeals waiting',
            icon: Icons.gavel_outlined,
            accent: _red,
            onTap: _openAppeals,
          ),
        ),
      ],
    );
  }

  Widget _overviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.38,
      children: [
        _OverviewCard(
          label: 'Workers',
          value: _n('workers'),
          icon: Icons.badge_outlined,
          accent: _teal,
        ),
        _OverviewCard(
          label: 'Homeowners',
          value: _n('homeowners'),
          icon: Icons.home_work_outlined,
          accent: _navy,
        ),
        _OverviewCard(
          label: 'Open Jobs',
          value: _n('open_jobs'),
          icon: Icons.work_outline_rounded,
          accent: _orange,
        ),
        _OverviewCard(
          label: 'Active Jobs',
          value: _n('active_jobs'),
          icon: Icons.play_circle_outline_rounded,
          accent: _green,
        ),
        _OverviewCard(
          label: 'Completed',
          value: _n('completed_jobs'),
          icon: Icons.task_alt_rounded,
          accent: const Color(0xFF6C63D8),
        ),
        _OverviewCard(
          label: 'Suspended',
          value: _n('suspended_users'),
          icon: Icons.pause_circle_outline_rounded,
          accent: _red,
        ),
      ],
    );
  }

  Widget _quickActions() {
    return Column(
      children: [
        _ActionCard(
          title: 'Worker Verifications',
          subtitle: '${_n('pending_verifications')} waiting for review',
          icon: Icons.verified_user_outlined,
          accent: _teal,
          badge:
              _n('pending_verifications') > 0
                  ? _n('pending_verifications').toString()
                  : null,
          onTap: _openVerifications,
        ),
        const SizedBox(height: 11),
        _ActionCard(
          title: 'Suspension Appeals',
          subtitle:
              _n('pending_appeals') == 0
                  ? 'No appeals waiting right now'
                  : '${_n('pending_appeals')} ${_n('pending_appeals') == 1 ? 'appeal' : 'appeals'} waiting for review',
          icon: Icons.rate_review_outlined,
          accent: _red,
          badge:
              _n('pending_appeals') > 0
                  ? _n('pending_appeals').toString()
                  : null,
          onTap: _openAppeals,
        ),
        const SizedBox(height: 11),
        _ActionCard(
          title: 'User Management',
          subtitle: 'Search, suspend, restore or deactivate accounts',
          icon: Icons.manage_accounts_outlined,
          accent: _navy,
          onTap: _openUsers,
        ),
      ],
    );
  }

  Widget _verificationHealth() {
    final approved = _n('approved_workers');
    final rejected = _n('rejected_workers');
    final pending = _n('pending_verifications');
    final total = approved + rejected + pending;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE7EDF2)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.045),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HealthNumber(label: 'Approved', value: approved, accent: _green),
              _verticalDivider(),
              _HealthNumber(label: 'Pending', value: pending, accent: _orange),
              _verticalDivider(),
              _HealthNumber(label: 'Rejected', value: rejected, accent: _red),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  if (approved > 0)
                    Expanded(
                      flex: approved,
                      child: Container(height: 7, color: _green),
                    ),
                  if (pending > 0)
                    Expanded(
                      flex: pending,
                      child: Container(height: 7, color: _orange),
                    ),
                  if (rejected > 0)
                    Expanded(
                      flex: rejected,
                      child: Container(height: 7, color: _red),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 42, color: const Color(0xFFE7EDF2));
  }

  Future<void> _openVerifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminWorkerVerificationsScreen()),
    );

    if (mounted) {
      _load();
    }
  }

  Future<void> _openAppeals() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminAccountAppealsScreen()),
    );

    if (mounted) {
      _load();
    }
  }

  Future<void> _openUsers() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AdminUsersScreen()));

    if (mounted) {
      _load();
    }
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: _red, size: 38),
          const SizedBox(height: 11),
          const Text(
            'Could not load dashboard',
            style: TextStyle(
              color: _slate,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _load,
            style: FilledButton.styleFrom(backgroundColor: _teal),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  int _n(String key) {
    return int.tryParse(_stats[key]?.toString() ?? '') ?? 0;
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final int value;
  final String caption;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.17)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: value > 0 ? accent : const Color(0xFFE9EEF2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        color: value > 0 ? Colors.white : _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                label,
                style: const TextStyle(
                  color: _slate,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                caption,
                style: const TextStyle(color: _muted, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF3)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: _slate,
                    fontSize: 23,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8EEF3)),
          ),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: _slate,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthNumber extends StatelessWidget {
  const _HealthNumber({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
