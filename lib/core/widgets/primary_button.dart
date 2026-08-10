import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: text,
      onPressed: onPressed,
      loading: isLoading,
      icon: icon,
    );
  }
}
