import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../guest_home.dart';
import '../../../homeowner_complete_profile.dart';
import '../../../homeowner_shell.dart';
import '../../../services/homeowner_profile_service.dart';
import '../../../services/worker_profile_service.dart';
import '../../../signup.dart';
import '../../../worker_complete_profile.dart';
import '../../../worker_home.dart';
import '../services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '0700000001');
  final _passwordController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _authService = AuthService();
  final _workerProfileService = WorkerProfileService();
  final _homeownerProfileService = HomeownerProfileService();

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
      duration: const Duration(milliseconds: 720),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
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

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

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

    final user = result.user!;
    final role = user['role']?.toString().toLowerCase();
    final fullName = user['full_name']?.toString() ?? '';
    final phone = user['phone']?.toString() ?? _phoneController.text.trim();
    final email = user['email']?.toString() ?? '';

    if (role == 'worker') {
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
    _showMessage('This account role is not supported.', isError: true);
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
                    ? const WorkerHomeScreen()
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
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
              isError ? const Color(0xFFE53E3E) : const Color(0xFF2A3D4E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF2A3D4E),
        body: Column(
          children: [
            FadeTransition(opacity: _fadeAnimation, child: const AuthHeader()),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(26, 22, 26, 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign in',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF395264),
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter your registered phone number and password.',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF718795),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 25),
                            AuthTextField(
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              label: 'Phone number',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                              ],
                              onSubmitted: (_) => _passwordFocus.requestFocus(),
                              validator: (value) {
                                final phone = value?.trim() ?? '';

                                if (phone.length < 9) {
                                  return 'Enter a valid phone number.';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            AuthTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _login(),
                              validator: (value) {
                                if ((value ?? '').length < 6) {
                                  return 'Password must contain at least 6 characters.';
                                }

                                return null;
                              },
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            AuthPrimaryButton(
                              label: 'Continue securely',
                              isLoading: _isLoading,
                              onPressed: _login,
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const SignUpScreen(),
                                          ),
                                        );
                                      },
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Create an account'),
                            ),
                            TextButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const GuestHomeScreen(),
                                          ),
                                        );
                                      },
                              child: const Text('Browse as a guest'),
                            ),
                          ],
                        ),
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
