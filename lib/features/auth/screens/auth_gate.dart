import 'package:flutter/material.dart';

import '../../../homeowner_complete_profile.dart';
import '../../admin/admin_dashboard_screen.dart';
import '../../profile/account_screen.dart';
import '../../../homeowner_shell.dart';
import '../../../services/homeowner_profile_service.dart';
import '../../../services/worker_profile_service.dart';
import '../../../worker_complete_profile.dart';
import '../../../worker_shell.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final WorkerProfileService _workerProfileService = WorkerProfileService();
  final HomeownerProfileService _homeownerProfileService =
      HomeownerProfileService();

  late final Future<Widget> _destination;

  @override
  void initState() {
    super.initState();
    _destination = _resolveDestination();
  }

  Future<Widget> _resolveDestination() async {
    final user = await _authService.currentUser();

    if (user == null) {
      return const LoginScreen();
    }

    final role = user['role']?.toString().toLowerCase() ?? '';
    final fullName = user['full_name']?.toString() ?? '';
    final phone = user['phone']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';

    if (role == 'admin') {
      return const AdminDashboardScreen();
    }

    if (role == 'worker') {
      final profileResult = await _workerProfileService.getProfile();

      if ((user['account_status']?.toString() ?? 'active') == 'suspended') {
        final rawProfile = profileResult['profile'];
        final profile =
            rawProfile is Map
                ? Map<String, dynamic>.from(rawProfile)
                : <String, dynamic>{};

        return AccountScreen(role: 'worker', user: user, profile: profile);
      }
      final profile = profileResult['profile'];
      final profileMap =
          profile is Map ? Map<String, dynamic>.from(profile) : null;

      final completed =
          profileResult['success'] == true &&
          profileMap != null &&
          profileMap['profile_completed'] == true;

      return completed
          ? const WorkerShell()
          : WorkerCompleteProfileScreen(phone: phone);
    }

    if (role == 'homeowner') {
      final profileResult = await _homeownerProfileService.getProfile();
      final completed =
          profileResult['success'] == true &&
          profileResult['profile_completed'] == true;

      return completed
          ? const HomeownerShell()
          : HomeownerCompleteProfileScreen(
            name: fullName,
            phone: phone,
            email: email,
          );
    }

    await _authService.logout();
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _destination,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        }

        return const _AuthLoadingScreen();
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 18),
              Text(
                'Opening WorkLink Africa…',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Checking your secure session',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
