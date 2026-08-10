import 'package:flutter/material.dart';

import '../../services/account_service.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AccountService();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _saving = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final result = await _service.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
      confirmation: _confirmController.text,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ?? 'Password request completed.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result['success'] == true) {
      Navigator.of(context).pop(true);
    }
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';

    if (password.length < 8) {
      return 'Use at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include at least one lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least one number.';
    }

    return null;
  }

  double get _strength {
    final value = _newController.text;
    var score = 0.0;

    if (value.length >= 8) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.25;
    if (RegExp(r'[a-z]').hasMatch(value)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.25;

    return score;
  }

  String get _strengthLabel {
    final value = _strength;
    if (value >= 1) return 'Excellent';
    if (value >= 0.75) return 'Strong';
    if (value >= 0.5) return 'Fair';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _PasswordHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 120),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
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
                      child: Column(
                        children: [
                          _PasswordField(
                            controller: _currentController,
                            label: 'Current Password',
                            visible: _showCurrent,
                            onToggle: () {
                              setState(() => _showCurrent = !_showCurrent);
                            },
                            validator:
                                (value) =>
                                    (value ?? '').isEmpty
                                        ? 'Enter your current password.'
                                        : null,
                          ),
                          const SizedBox(height: 14),
                          _PasswordField(
                            controller: _newController,
                            label: 'New Password',
                            visible: _showNew,
                            onChanged: (_) => setState(() {}),
                            onToggle: () {
                              setState(() => _showNew = !_showNew);
                            },
                            validator: _validateNewPassword,
                          ),
                          const SizedBox(height: 14),
                          _PasswordField(
                            controller: _confirmController,
                            label: 'Confirm New Password',
                            visible: _showConfirm,
                            onToggle: () {
                              setState(() => _showConfirm = !_showConfirm);
                            },
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return 'Confirm your new password.';
                              }
                              if (value != _newController.text) {
                                return 'The passwords do not match.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password Strength',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 11),
                          LinearProgressIndicator(
                            value: _strength,
                            minHeight: 9,
                            color: _primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            _strengthLabel,
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const _Requirement(text: 'At least 8 characters'),
                          const _Requirement(text: 'One uppercase letter'),
                          const _Requirement(text: 'One lowercase letter'),
                          const _Requirement(text: 'One number'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        color: colors.surface,
        elevation: 16,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: _primary),
                icon:
                    _saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.lock_reset_rounded),
                label: Text(
                  _saving ? 'Changing Password...' : 'Change Password',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordHeader extends StatelessWidget {
  const _PasswordHeader();

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
              Icons.lock_reset_rounded,
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
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a strong password you do not use elsewhere.',
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    required this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          ),
        ),
      ),
      validator: validator,
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: _primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
