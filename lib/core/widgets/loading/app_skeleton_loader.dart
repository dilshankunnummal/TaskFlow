import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/cards/app_card.dart';
import 'package:taskflow/core/widgets/loading/app_shimmer_box.dart';

final class AppSkeletonLoader extends StatelessWidget {
  const AppSkeletonLoader({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmerBox(width: 160, height: 16),
              const SizedBox(height: AppSpacing.md),
              AppShimmerBox(width: double.infinity, height: 12),
              const SizedBox(height: AppSpacing.sm),
              AppShimmerBox(width: 220, height: 12),
            ],
          ),
        );
      },
    );
  }
}
