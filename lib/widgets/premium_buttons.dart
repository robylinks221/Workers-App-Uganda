import 'package:flutter/material.dart';

const premiumButtonNavy = Color(0xFF164D7A);
const premiumButtonTeal = Color(0xFF1FB8B3);
const premiumButtonDanger = Color(0xFFD63031);

enum PremiumButtonSize {
  compact,
  regular,
  large,
}

class PremiumGradientButton extends StatelessWidget {
  const PremiumGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.size = PremiumButtonSize.regular,
    this.gradient,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final PremiumButtonSize size;
  final LinearGradient? gradient;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final height = switch (size) {
      PremiumButtonSize.compact => 44.0,
      PremiumButtonSize.regular => 52.0,
      PremiumButtonSize.large => 56.0,
    };

    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.55,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [
                  premiumButtonNavy,
                  Color(0xFF177989),
                  premiumButtonTeal,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: premiumButtonTeal.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Semantics(
              button: true,
              label: semanticLabel ?? label,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:
                      expanded ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (loading)
                      const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else if (icon != null)
                      Icon(icon, color: Colors.white, size: 20),
                    if (loading || icon != null) const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        loading ? 'Please wait...' : label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!expanded) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth) {
          return SizedBox(width: constraints.maxWidth, child: child);
        }

        return child;
      },
    );
  }
}

class PremiumOutlineButton extends StatelessWidget {
  const PremiumOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.size = PremiumButtonSize.regular,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final PremiumButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final height = switch (size) {
      PremiumButtonSize.compact => 44.0,
      PremiumButtonSize.regular => 52.0,
      PremiumButtonSize.large => 56.0,
    };

    final button = SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: premiumButtonTeal,
          backgroundColor: colors.surface,
          side: const BorderSide(
            color: premiumButtonTeal,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.10),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (icon != null)
              Icon(icon, size: 20),
            if (loading || icon != null) const SizedBox(width: 8),
            Flexible(
              child: Text(
                loading ? 'Please wait...' : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!expanded) return button;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth) {
          return SizedBox(width: constraints.maxWidth, child: button);
        }

        return button;
      },
    );
  }
}

class PremiumDangerButton extends StatelessWidget {
  const PremiumDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return PremiumGradientButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      loading: loading,
      expanded: expanded,
      gradient: const LinearGradient(
        colors: [
          Color(0xFFB91C1C),
          premiumButtonDanger,
          Color(0xFFEF5350),
        ],
      ),
    );
  }
}

class PremiumActionIconButton extends StatelessWidget {
  const PremiumActionIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.active = false,
    this.loading = false,
    this.activeColor = const Color(0xFFE94877),
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool active;
  final bool loading;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = active ? activeColor : premiumButtonTeal;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: colors.surface,
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, color: foreground, size: 23),
            ),
          ),
        ),
      ),
    );
  }
}
