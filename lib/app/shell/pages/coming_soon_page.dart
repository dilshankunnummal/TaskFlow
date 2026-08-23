import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_spacing.dart';
import 'package:taskflow/core/widgets/empty/app_empty_state.dart';

final class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl + AppSpacing.xl),
          child: AppEmptyState(
            title: '$title is on its way',
            message: message,
            icon: icon,
          ),
        ),
      ),
    );
  }
}
