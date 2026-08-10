import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'worker_complete_profile.dart';
import 'homeowner_complete_profile.dart';
import 'features/auth/services/auth_service.dart';
import 'widgets/app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colours  (same tokens used across all screens)
// ─────────────────────────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF1FB8B3); // terracotta — buttons & CTAs
const Color _kHeroLight = Color(
  0xFF176B80,
); // lighter slate — hero gradient top
const Color _kInputFill = Color(0xFFF0F8FA); // warm tint — input background
const Color _kHint = Color(0xFF8092A3); // warm muted placeholder
const Color _kText = Color(0xFF17324D); // dark slate — headings & body
const Color _kSubText = Color(0xFF667C8F); // muted secondary text
const Color _kGold = Color(0xFFFFB300); // same as primary — accent
const Color _kError = Color(0xFFE53E3E);

// ─────────────────────────────────────────────────────────────────────────────
// Sign Up Screen
// ─────────────────────────────────────────────────────────────────────────────
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String _role = 'homeowner'; // 'homeowner' | 'worker'

  late AnimationController _ac;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Enter a valid Ugandan phone number';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  // ── Sign Up — registers with Laravel and saves the Sanctum token ────────────
  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false) || _loading) {
      return;
    }

    setState(() => _loading = true);

    final result = await _authService.register(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: '',
      password: _passwordCtrl.text,
      passwordConfirmation: _confirmCtrl.text,
      role: _role,
      location: '',
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (!result.success) {
      final message = _firstRegistrationError(result);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: _kError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      return;
    }

    final user = result.user;
    final registeredRole = user?['role']?.toString() ?? _role;

    if (registeredRole == 'worker') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => WorkerCompleteProfileScreen(phone: _phoneCtrl.text.trim()),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => HomeownerCompleteProfileScreen(
              name: _nameCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
            ),
      ),
    );
  }

  String _firstRegistrationError(AuthResult result) {
    final errors = result.errors;

    if (errors != null && errors.isNotEmpty) {
      final first = errors.values.first;

      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }

      return first.toString();
    }

    return result.message;
  }

  // ── Password strength helpers ────────────────────────────────────────────────
  int _strength(String p) {
    if (p.isEmpty) return 0;
    if (p.length < 4) return 1;
    if (p.length < 8) return 2;
    return 3;
  }

  Color _strengthColor(int s) =>
      [Colors.transparent, _kError, _kGold, _kPrimary][s.clamp(0, 3)];

  String _strengthLabel(int s) => ['', 'Weak', 'Fair', 'Strong'][s.clamp(0, 3)];

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: Column(
        children: [
          // ── Hero strip ──────────────────────────────────────────────────────
          SizedBox(
            height: 238,
            child: Stack(
              children: [
                const Positioned.fill(child: _HeroBackground()),
                SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ← Back to login
                          GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Back to login',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Create Your Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create a secure account and choose how you want to use WorkLink Africa.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White card ──────────────────────────────────────────────────────
          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 30,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 34),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Title
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: _kPrimary.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: _kPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Your Account',
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                      color: _kText,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'It only takes a few minutes.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _kSubText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Role toggle ────────────────────────────────────
                        _RoleToggle(
                          selected: _role,
                          onChanged: (r) => setState(() => _role = r),
                        ),
                        const SizedBox(height: 20),

                        // ── Full name ──────────────────────────────────────
                        _PillField(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          hint: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          onSubmit:
                              () => FocusScope.of(
                                context,
                              ).requestFocus(_phoneFocus),
                          validator: _validateName,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 14),

                        // ── Phone ──────────────────────────────────────────
                        _PillField(
                          controller: _phoneCtrl,
                          focusNode: _phoneFocus,
                          hint: 'Phone Number  (07XX XXX XXX)',
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          textInputAction: TextInputAction.next,
                          onSubmit:
                              () => FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocus),
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 14),

                        // ── Password ───────────────────────────────────────
                        _PillField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePass,
                          textInputAction: TextInputAction.next,
                          onSubmit:
                              () => FocusScope.of(
                                context,
                              ).requestFocus(_confirmFocus),
                          validator: _validatePassword,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: GestureDetector(
                            onTap:
                                () => setState(
                                  () => _obscurePass = !_obscurePass,
                                ),
                            child: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _kHint,
                              size: 20,
                            ),
                          ),
                        ),

                        // Strength bar
                        if (_passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _StrengthBar(
                            strength: _strength(_passwordCtrl.text),
                            color: _strengthColor(
                              _strength(_passwordCtrl.text),
                            ),
                            label: _strengthLabel(
                              _strength(_passwordCtrl.text),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // ── Confirm password ───────────────────────────────
                        _PillField(
                          controller: _confirmCtrl,
                          focusNode: _confirmFocus,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onSubmit: _handleSignUp,
                          validator: _validateConfirm,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: GestureDetector(
                            onTap:
                                () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                            child: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _kHint,
                              size: 20,
                            ),
                          ),
                        ),

                        // Match indicator
                        if (_confirmCtrl.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 6),
                            child: Row(
                              children: [
                                Icon(
                                  _confirmCtrl.text == _passwordCtrl.text
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 14,
                                  color:
                                      _confirmCtrl.text == _passwordCtrl.text
                                          ? _kPrimary
                                          : _kError,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _confirmCtrl.text == _passwordCtrl.text
                                      ? 'Passwords match'
                                      : 'Passwords do not match',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        _confirmCtrl.text == _passwordCtrl.text
                                            ? _kPrimary
                                            : _kError,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 28),

                        // ── Sign Up button ─────────────────────────────────
                        AppButton(
                          label: 'Create Your Account',
                          icon: Icons.arrow_forward_rounded,
                          loading: _loading,
                          onPressed: _loading ? null : _handleSignUp,
                        ),
                        const SizedBox(height: 20),

                        // ── Terms notice ───────────────────────────────────
                        Text(
                          'By signing up you agree to our Terms & Conditions '
                          'and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Already have account ───────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.maybePop(context),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: _kPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role toggle — Homeowner / Maid
// ─────────────────────────────────────────────────────────────────────────────
class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kInputFill,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _RoleOption(
            label: 'Homeowner',
            icon: Icons.home_rounded,
            value: 'homeowner',
            selected: selected == 'homeowner',
            onTap: () => onChanged('homeowner'),
          ),
          _RoleOption(
            label: 'Maid / Worker',
            icon: Icons.person_rounded,
            value: 'maid',
            selected: selected == 'worker',
            onTap: () => onChanged('worker'),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : _kSubText),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _kSubText,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password strength bar
// ─────────────────────────────────────────────────────────────────────────────
class _StrengthBar extends StatelessWidget {
  const _StrengthBar({
    required this.strength,
    required this.color,
    required this.label,
  });
  final int strength;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(3, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength ? color : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable pill input field
// ─────────────────────────────────────────────────────────────────────────────
class _PillField extends StatelessWidget {
  const _PillField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmit,
    this.suffixIcon,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmit;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onFieldSubmitted: (_) => onSubmit?.call(),
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: _kText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kHint, fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 10),
          child: Icon(icon, color: _kHint, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        suffixIcon:
            suffixIcon != null
                ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffixIcon,
                )
                : null,
        filled: true,
        fillColor: _kInputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _kError, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _kError, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, height: 1.2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero background  (slate gradient + decorative circles & leaves)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(painter: _HeroPainter()),
    );
  }
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF123F67), Color(0xFF176B80), Color(0xFF1FB8B3)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    canvas.drawCircle(
      Offset(size.width + 10, -30),
      130,
      Paint()..color = Colors.white.withOpacity(0.10),
    );
    canvas.drawCircle(
      Offset(size.width - 20, 60),
      90,
      Paint()..color = Colors.white.withOpacity(0.07),
    );
    canvas.drawCircle(
      Offset(-20, size.height - 20),
      70,
      Paint()..color = Colors.white.withOpacity(0.08),
    );
    _drawLeaf(
      canvas,
      Offset(size.width - 40, size.height * 0.7),
      60,
      -0.4,
      Colors.white.withOpacity(0.12),
    );
    _drawLeaf(
      canvas,
      Offset(size.width - 10, size.height * 0.3),
      40,
      0.3,
      Colors.white.withOpacity(0.09),
    );
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double size,
    double angle,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final path = Path();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    path.moveTo(0, -size);
    path.cubicTo(size * 0.6, -size * 0.6, size * 0.6, size * 0.6, 0, size);
    path.cubicTo(-size * 0.6, size * 0.6, -size * 0.6, -size * 0.6, 0, -size);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
