import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message = 'Please wait...', this.size = 42});

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          AppText.body(
            message,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLoader(message: message),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.loading,
    this.message = 'Loading...',
  });

  final Widget child;
  final bool loading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (loading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppLoader(message: message),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
