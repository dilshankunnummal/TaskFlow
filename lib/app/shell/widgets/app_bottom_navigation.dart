import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/glass/glass_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

final class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      label: 'Home',
    ),
    _NavDestination(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Projects',
    ),
    _NavDestination(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final count = AppBottomNavigation._destinations.length;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: GlassContainer(
        borderRadius: AppRadius.pillRadius,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Width of each nav item slot
            final itemWidth = constraints.maxWidth / count;

            return Stack(
              children: [
                // ── Sliding pill indicator (full item width, same as original) ─
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  left: currentIndex * itemWidth,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: const _SlidingPill(),
                ),

                // ── Nav items (rendered above the pill) ────────────────────
                Row(
                  children: [
                    for (var i = 0;
                        i < AppBottomNavigation._destinations.length;
                        i++)
                      Expanded(
                        child: _AppNavItem(
                          destination: AppBottomNavigation._destinations[i],
                          isSelected: currentIndex == i,
                          onTap: () => _onDestinationSelected(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliding pill background
// ─────────────────────────────────────────────────────────────────────────────

class _SlidingPill extends StatelessWidget {
  const _SlidingPill();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: AppRadius.pillRadius,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav item with scale bounce on selection
// ─────────────────────────────────────────────────────────────────────────────

final class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

final class _AppNavItem extends StatelessWidget {
  const _AppNavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withOpacity(0.56);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon with pop-scale bounce when selected ──────────────────
            TweenAnimationBuilder<double>(
              // Changing the key forces the animation to re-run every time
              // isSelected flips, so each tap produces a fresh bounce.
              key: ValueKey<bool>(isSelected),
              tween: isSelected
                  ? Tween(begin: 0.72, end: 1.0) // pop-in on select
                  : Tween(begin: 1.0, end: 1.0),  // no anim on deselect
              duration: const Duration(milliseconds: 380),
              curve: Curves.elasticOut,
              builder: (context, scale, _) => Transform.scale(
                scale: scale,
                child: AnimatedSwitcher(
                  duration: AppMotion.micro,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? destination.activeIcon : destination.icon,
                    key: ValueKey<bool>(isSelected),
                    size: 22,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // ── Label with weight/color transition ────────────────────────
            AnimatedDefaultTextStyle(
              duration: AppMotion.transition,
              curve: AppMotion.curve,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(destination.label),
            ),
          ],
        ),
      ),
    );
  }
}
