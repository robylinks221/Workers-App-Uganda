import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';

class JobChatLauncher {
  JobChatLauncher._();

  static Future<void> open({
    required BuildContext context,
    required int jobId,
  }) async {
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
            Text('Opening conversation...'),
          ],
        ),
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final ChatConversation conversation = await ChatService()
          .createJobConversation(jobId);

      if (!context.mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();

      await navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );
    } on ChatServiceException catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();

      messenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();

      messenger.showSnackBar(
        SnackBar(
          content: Text('Unable to open conversation. $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}
