import 'package:flutter/material.dart';

import '../../services/account_service.dart';
import '../../storage/token_storage.dart';
import '../auth/screens/login_screen.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);
const _danger = Color(0xFFD63031);
const _muted = Color(0xFF617889);

class AccountControlScreen extends StatefulWidget {
  const AccountControlScreen({super.key});

  @override
  State<AccountControlScreen> createState() => _AccountControlScreenState();
}

class _AccountControlScreenState extends State<AccountControlScreen> {
  final AccountService _service = AccountService();

  bool _busy = false;

  Future<String?> _askForPassword({
    required String title,
    required String message,
    required String button,
    bool destructive = false,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    // Let the keyboard finish closing before opening the dialog.
    await Future<void>.delayed(const Duration(milliseconds: 120));

    if (!mounted) {
      return null;
    }

    return showDialog<String>(
      context: context,
      useSafeArea: true,
      builder:
          (_) => _PasswordConfirmDialog(
            title: title,
            message: message,
            button: button,
            destructive: destructive,
          ),
    );
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            scrollable: true,
            icon: const Icon(
              Icons.delete_forever_outlined,
              color: _danger,
              size: 46,
            ),
            title: const Text('Delete Your Account?'),
            content: const Text(
              'Your account will be hidden immediately. You will have 30 days to restore it by logging in again. After 30 days, your personal profile information and uploaded identity documents will be removed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, height: 1.45),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Account'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: _danger),
                child: const Text('Continue'),
              ),
            ],
          ),
    );

    return result == true;
  }

  Future<void> _deactivate() async {
    final password = await _askForPassword(
      title: 'Deactivate Account',
      message:
          'Your profile will be hidden and you will be logged out. Nothing is deleted. Log in again whenever you want to reactivate your account.',
      button: 'Deactivate',
    );

    if (password == null || !mounted) {
      return;
    }

    setState(() => _busy = true);

    final result = await _service.deactivateAccount(password: password);

    if (!mounted) return;

    setState(() => _busy = false);

    if (result['success'] != true) {
      _message(
        result['message']?.toString() ?? 'Unable to deactivate account.',
        error: true,
      );
      return;
    }

    await _finishAndLogout(
      'Account deactivated. You can reactivate it by logging in again.',
    );
  }

  Future<void> _delete() async {
    if (!await _confirmDelete() || !mounted) {
      return;
    }

    final password = await _askForPassword(
      title: 'Confirm Account Deletion',
      message: 'Enter your password to schedule permanent account deletion.',
      button: 'Delete Account',
      destructive: true,
    );

    if (password == null || !mounted) {
      return;
    }

    setState(() => _busy = true);

    final result = await _service.requestAccountDeletion(password: password);

    if (!mounted) return;

    setState(() => _busy = false);

    if (result['success'] != true) {
      _message(
        result['message']?.toString() ?? 'Unable to schedule account deletion.',
        error: true,
      );
      return;
    }

    await _finishAndLogout(
      'Account scheduled for deletion. Log in within 30 days if you change your mind.',
    );
  }

  Future<void> _finishAndLogout(String message) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await TokenStorage.removeToken();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: _primary,
              size: 46,
            ),
            title: const Text('Done'),
            content: Text(message, textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
    );

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? _danger : _navy,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Control')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          children: [
            const Text(
              'MANAGE YOUR ACCOUNT',
              style: TextStyle(
                color: _primary,
                fontSize: 9.5,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'You are in control',
              style: TextStyle(
                color: _navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Pause your account temporarily or request permanent deletion.',
              style: TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            _ControlCard(
              icon: Icons.pause_circle_outline_rounded,
              iconColor: _primary,
              title: 'Deactivate Account',
              subtitle:
                  'Temporarily hide your account. Your information stays safe and you can return by logging in again.',
              buttonLabel: 'Deactivate Account',
              onPressed: _deactivate,
            ),
            const SizedBox(height: 16),
            _ControlCard(
              icon: Icons.delete_outline_rounded,
              iconColor: _danger,
              title: 'Delete My Account',
              subtitle:
                  'Hide your account now and permanently remove personal profile data after a 30-day recovery period.',
              buttonLabel: 'Delete Account',
              destructive: true,
              onPressed: _delete,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: _navy,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Suspension is different. Only an administrator can suspend an account for a safety or policy issue. A suspended account must use the appeal process.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 22),
              const Center(child: CircularProgressIndicator(color: _primary)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PasswordConfirmDialog extends StatefulWidget {
  const _PasswordConfirmDialog({
    required this.title,
    required this.message,
    required this.button,
    required this.destructive,
  });

  final String title;
  final String message;
  final String button;
  final bool destructive;

  @override
  State<_PasswordConfirmDialog> createState() => _PasswordConfirmDialogState();
}

class _PasswordConfirmDialogState extends State<_PasswordConfirmDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _obscure = true;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please enter your password.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: const TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Your Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscure = !_obscure);
                  },
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: widget.destructive ? _danger : _primary,
          ),
          child: Text(widget.button),
        ),
      ],
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              destructive
                  ? _danger.withValues(alpha: 0.18)
                  : _primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child:
                destructive
                    ? OutlinedButton.icon(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _danger,
                        side: const BorderSide(color: _danger),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    )
                    : FilledButton.icon(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(backgroundColor: _primary),
                      icon: const Icon(Icons.pause_circle_outline_rounded),
                      label: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
