import 'package:flutter/material.dart';

class PremiumFloatingNavItem {
  const PremiumFloatingNavItem({
    required this.label,
    required this.icon,
    this.badgeCount = 0,
    this.badgeColor = const Color(0xFFE53935),
  });

  final String label;
  final IconData icon;
  final int badgeCount;
  final Color badgeColor;
}

class PremiumFloatingNavBar extends StatelessWidget {
  const PremiumFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PremiumFloatingNavItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colors.surface : const Color(0xFF151925);
    final selectedColor = const Color(0xFF1FB8B3);
    final unselectedColor =
        isDark ? const Color(0xFF9EACBA) : const Color(0xFF8F98A8);

    return Material(
      color: backgroundColor,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 4),
            child: Row(
              children: List.generate(items.length, (index) {
                final selected = currentIndex == index;

                return Expanded(
                  child: _NavItemButton(
                    item: items[index],
                    selected: selected,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final PremiumFloatingNavItem item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return Semantics(
      button: true,
      selected: selected,
      label:
          item.badgeCount > 0
              ? '${item.label}, ${item.badgeCount} new items'
              : item.label,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: () {
            Feedback.forTap(context);
            onTap();
          },
          radius: 34,
          splashColor: selectedColor.withValues(alpha: 0.10),
          highlightColor: selectedColor.withValues(alpha: 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 38,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: 40,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color:
                            selected
                                ? selectedColor.withValues(alpha: 0.14)
                                : Colors.transparent,
                      ),
                      child: Icon(item.icon, size: 22, color: color),
                    ),
                    Positioned(
                      top: -3,
                      right: -1,
                      child: _AnimatedBadge(
                        count: item.badgeCount,
                        color: item.badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final visible = count > 0;
    final label = count > 99 ? '99+' : count.toString();

    return AnimatedScale(
      scale: visible ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: Container(
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
