import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/avatars/app_avatar.dart';
import 'package:taskflow/core/widgets/chips/app_chip.dart';
import 'package:taskflow/features/auth/domain/entities/user_entity.dart';

final class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.user,
    required this.organizationName,
    super.key,
  });

  final UserEntity user;
  final String organizationName;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String get _firstName {
    final trimmed = user.name.trim();
    if (trimmed.isEmpty) {
      return 'there';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get _roleLabel => user.isOrgAdmin ? 'Org Admin' : 'Member';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(name: user.name, size: 52),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting, $_firstName', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      organizationName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.64),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppChip(label: _roleLabel, icon: Icons.verified_user_outlined),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
