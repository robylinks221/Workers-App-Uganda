import 'package:flutter/material.dart';

enum AppButtonType { primary, outline, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.type = AppButtonType.primary,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonType type;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final colors = Theme.of(context).colorScheme;

    const height = 56.0;
    final radius = BorderRadius.circular(height / 2);

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (loading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (loading || icon != null) const SizedBox(width: 9),
        Flexible(
          child: Text(
            loading ? 'Please wait...' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );

    late Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF164D7A),
                  Color(0xFF177989),
                  Color(0xFF1FB8B3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: radius,
              boxShadow:
                  enabled
                      ? [
                        BoxShadow(
                          color: const Color(
                            0xFF1FB8B3,
                          ).withValues(alpha: 0.28),
                          blurRadius: 15,
                          offset: const Offset(0, 7),
                        ),
                      ]
                      : const [],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white),
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        break;

      case AppButtonType.outline:
        button = SizedBox(
          height: height,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1FB8B3),
              backgroundColor: colors.surface,
              side: const BorderSide(color: Color(0xFF1FB8B3), width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: radius),
              padding: const EdgeInsets.symmetric(horizontal: 22),
            ),
            child: content,
          ),
        );
        break;

      case AppButtonType.danger:
        button = AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB91C1C),
                  Color(0xFFD63031),
                  Color(0xFFEF5350),
                ],
              ),
              borderRadius: radius,
              boxShadow:
                  enabled
                      ? [
                        BoxShadow(
                          color: const Color(
                            0xFFD63031,
                          ).withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : const [],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white),
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        break;
    }

    if (!expanded) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
