import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/services/auth_service.dart';

class LogoutHelper {
  LogoutHelper._();

  static bool _loggingOut = false;

  static Future<void> confirmAndLogout(BuildContext context) async {
    if (_loggingOut) {
      return;
    }

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD87C53),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    _loggingOut = true;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Logging out...'),
          ],
        ),
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await AuthService().logout();

      if (!context.mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      _loggingOut = false;
    }
  }
}
