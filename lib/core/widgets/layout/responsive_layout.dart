import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_breakpoints.dart';

final class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.phone,
    super.key,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder phone;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (AppBreakpoints.isDesktop(width) && desktop != null) {
          return desktop!(context);
        }
        if (AppBreakpoints.isTablet(width) && tablet != null) {
          return tablet!(context);
        }
        return phone(context);
      },
    );
  }
}

final class BentoGrid extends StatelessWidget {
  const BentoGrid({
    required this.children,
    super.key,
    this.gutter = 16,
  });

  final List<BentoItem> children;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppBreakpoints.isDesktop(constraints.maxWidth)
            ? 3
            : AppBreakpoints.isTablet(constraints.maxWidth)
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: gutter,
            crossAxisSpacing: gutter,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) => children[index].child,
        );
      },
    );
  }
}

final class BentoItem {
  const BentoItem({required this.child, this.span = 1});

  final Widget child;
  final int span;
}
