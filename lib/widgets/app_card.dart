import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.radius = AppRadius.card,
    this.elevated = false,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double radius;
  final bool elevated;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final cardColor =
        backgroundColor ?? (dark ? AppColors.darkSurface : AppColors.surface);

    final cardBorder =
        borderColor ?? (dark ? AppColors.darkBorder : AppColors.border);

    final decoration = BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: cardBorder),
      boxShadow: elevated ? AppShadows.elevatedCard : AppShadows.card,
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: decoration,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.margin,
    this.elevated = false,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? margin;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = dark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return AppCard(
      margin: margin,
      elevated: elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        dark
                            ? const Color(0xFF14313A)
                            : AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 21),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      elevated: true,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF14313A) : AppColors.iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color:
                        dark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color:
                        dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_outlined,
              color:
                  dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
