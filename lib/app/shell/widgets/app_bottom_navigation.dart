import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/theme/app_motion.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/glass/glass_container.dart';

final class AppBottomNavigation extends StatelessWidget {
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

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: GlassContainer(
        borderRadius: AppRadius.pillRadius,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: [
            for (var index = 0; index < _destinations.length; index++)
              Expanded(
                child: _AppNavItem(
                  destination: _destinations[index],
                  isSelected: navigationShell.currentIndex == index,
                  onTap: () => _onDestinationSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
      child: AnimatedContainer(
        duration: AppMotion.transition,
        curve: AppMotion.curve,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.14) : Colors.transparent,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.micro,
              child: Icon(
                isSelected ? destination.activeIcon : destination.icon,
                key: ValueKey<bool>(isSelected),
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AnimatedDefaultTextStyle(
              duration: AppMotion.transition,
              curve: AppMotion.curve,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
