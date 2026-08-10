import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../guest_home.dart';
import '../../../homeowner_complete_profile.dart';
import '../../../homeowner_shell.dart';
import '../../../services/homeowner_profile_service.dart';
import '../../../services/worker_profile_service.dart';
import '../../../signup.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../widgets/app_button.dart';
import '../../../worker_complete_profile.dart';
import '../../../worker_shell.dart';
import '../services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../../admin/admin_dashboard_screen.dart';
import '../../profile/account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController(
    text: '0700000001',
  );

  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final AuthService _authService = AuthService();
  final WorkerProfileService _workerProfileService = WorkerProfileService();
  final HomeownerProfileService _homeownerProfileService =
      HomeownerProfileService();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final result = await _authService.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!result.success || result.user == null) {
      setState(() => _isLoading = false);
      _showMessage(result.message, isError: true);
      return;
    }

    if (result.reactivated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.restoredDeletion
                ? 'Your deletion request was cancelled and your account was restored.'
                : 'Welcome back. Your account has been reactivated.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    final user = result.user!;
    final role = user['role']?.toString().toLowerCase() ?? '';
    final fullName = user['full_name']?.toString() ?? '';
    final phone = user['phone']?.toString() ?? _phoneController.text.trim();
    final email = user['email']?.toString() ?? '';

    if (role == 'admin') {
      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        (route) => false,
      );

      return;
    }

    if (role == 'worker') {
      if ((user['account_status']?.toString() ?? 'active') == 'suspended') {
        final profileResult = await _workerProfileService.getProfile();
        if (!mounted) return;
        setState(() => _isLoading = false);
        final rawProfile = profileResult['profile'];
        final profile =
            rawProfile is Map
                ? Map<String, dynamic>.from(rawProfile)
                : <String, dynamic>{};
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (_) =>
                    AccountScreen(role: 'worker', user: user, profile: profile),
          ),
          (_) => false,
        );
        return;
      }

      await _routeWorkerAfterLogin(phone: phone);
      return;
    }

    if (role == 'homeowner') {
      await _routeHomeownerAfterLogin(
        fullName: fullName,
        phone: phone,
        email: email,
      );
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = false);
    _showMessage(
      'We could not open this account. Please contact support.',
      isError: true,
    );
  }

  Future<void> _routeWorkerAfterLogin({required String phone}) async {
    final profileResult = await _workerProfileService.getProfile();

    if (!mounted) return;

    setState(() => _isLoading = false);

    final profile = profileResult['profile'];
    final profileMap =
        profile is Map ? Map<String, dynamic>.from(profile) : null;

    final completed =
        profileResult['success'] == true &&
        profileMap != null &&
        profileMap['profile_completed'] == true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) =>
                completed
                    ? const WorkerShell()
                    : WorkerCompleteProfileScreen(phone: phone),
      ),
    );
  }

  Future<void> _routeHomeownerAfterLogin({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    final profileResult = await _homeownerProfileService.getProfile();

    if (!mounted) return;

    setState(() => _isLoading = false);

    final completed =
        profileResult['success'] == true &&
        profileResult['profile_completed'] == true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) =>
                completed
                    ? const HomeownerShell()
                    : HomeownerCompleteProfileScreen(
                      name: fullName,
                      phone: phone,
                      email: email,
                    ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? AppColors.error : AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      );
  }

  void _openSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  void _browseAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GuestHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor:
            dark ? const Color(0xFF0F1722) : const Color(0xFFF4F8FB),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const AuthHeader(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
              sliver: SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: dark ? 0.26 : 0.10,
                          ),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1FB8B3,
                                  ).withValues(alpha: 0.11),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.lock_open_rounded,
                                  color: Color(0xFF1FB8B3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sign in securely',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Use your phone number and password.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            onFieldSubmitted: (_) {
                              _passwordFocus.requestFocus();
                            },
                            validator: (value) {
                              final phone = value?.trim() ?? '';

                              if (phone.length < 9) {
                                return 'Enter a valid phone number.';
                              }

                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: 'e.g. 0700000001',
                              prefixIcon: Icon(Icons.phone_android_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Password must contain at least 6 characters.';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip:
                                    _obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          AppButton(
                            label: 'Continue securely',
                            icon: Icons.arrow_forward_rounded,
                            loading: _isLoading,
                            onPressed: _login,
                          ),
                          const SizedBox(height: 13),
                          AppButton(
                            label: 'Create an account',
                            icon: Icons.person_add_alt_1_rounded,
                            type: AppButtonType.outline,
                            onPressed: _isLoading ? null : _openSignUp,
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: _isLoading ? null : _browseAsGuest,
                            icon: const Icon(Icons.travel_explore_outlined),
                            label: const Text('Browse as a guest'),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1FB8B3,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 18,
                                  color: Color(0xFF1FB8B3),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your login is protected and securely connected.',
                                    style: TextStyle(
                                      color: Color(0xFF177989),
                                      fontSize: 11.5,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
