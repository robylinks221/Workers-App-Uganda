import 'package:flutter/material.dart';

import '../../services/account_service.dart';
import '../../services/logout_helper.dart';
import 'change_password_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SecurityHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 110),
                children: [
                  _SecurityScoreCard(),
                  const SizedBox(height: 16),
                  _SecurityCard(
                    children: [
                      _SecurityTile(
                        icon: Icons.lock_reset_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      _SecurityTile(
                        icon: Icons.devices_other_rounded,
                        title: 'Log Out Other Devices',
                        subtitle: 'Keep this device logged in',
                        onTap: () => _askForPassword(context, logoutAll: false),
                      ),
                      _SecurityTile(
                        icon: Icons.logout_rounded,
                        title: 'Log Out All Devices',
                        subtitle: 'End every active login session',
                        danger: true,
                        onTap: () => _askForPassword(context, logoutAll: true),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: _primary),
                        SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'Two-factor authentication will be available in a future update.',
                            style: TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _askForPassword(
    BuildContext context, {
    required bool logoutAll,
  }) async {
    final controller = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              logoutAll ? 'Log Out All Devices' : 'Log Out Other Devices',
            ),
            content: TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isNotEmpty) {
                    Navigator.pop(dialogContext, value);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: logoutAll ? Colors.red.shade700 : _primary,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
    );

    controller.dispose();

    if (password == null || !context.mounted) return;

    final service = AccountService();
    final result =
        logoutAll
            ? await service.logoutAllDevices(password: password)
            : await service.logoutOtherDevices(password: password);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? 'Request completed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (logoutAll && result['success'] == true) {
      await LogoutHelper.confirmAndLogout(context);
    }
  }
}

class _SecurityHeader extends StatelessWidget {
  const _SecurityHeader();

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
              Icons.security_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password & Security',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Protect your account and manage active sessions.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
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

class _SecurityScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Score',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.9,
            minHeight: 9,
            color: _primary,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          SizedBox(height: 10),
          Text(
            'Excellent • Your account is well protected',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = danger ? Colors.red.shade700 : _primary;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 8,
          ),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: danger ? color : colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right_rounded, color: color),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Divider(height: 1, color: colors.outlineVariant),
          ),
      ],
    );
  }
}
