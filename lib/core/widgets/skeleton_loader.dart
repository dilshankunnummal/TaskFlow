import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_radius.dart';
import 'package:taskflow/core/theme/app_spacing.dart';

class SkeletonBox extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;

  const SkeletonBox({super.key, required this.height, this.width, this.radius});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_controller.value * 0.3),
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: base,
              borderRadius: widget.radius ?? AppRadius.cardRadius,
            ),
          ),
        );
      },
    );
  }
}

class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 18, width: 140),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(height: 14, width: 200),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              SkeletonBox(height: 20, width: 60, radius: BorderRadius.all(Radius.circular(999))),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(height: 20, width: 60, radius: BorderRadius.all(Radius.circular(999))),
            ],
          ),
        ],
      ),
    );
  }
}

class ProjectsListSkeleton extends StatelessWidget {
  final int itemCount;
  final int columns;

  const ProjectsListSkeleton({super.key, this.itemCount = 6, this.columns = 1});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 176,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
          ),
          child: const ProjectCardSkeleton(),
        );
      },
    );
  }
}