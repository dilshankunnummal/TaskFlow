import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/loading/app_shimmer_box.dart';

/// A generic loading state widget that uses shimmer bars instead of a spinner.
/// Used on the splash screen and any full-page loading fallback.
final class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.message, this.size = 28});

  final String? message;

  /// Kept for API compatibility — controls the width of the shimmer bar.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppShimmerBox(width: size * 3, height: size * 0.3),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
