import 'package:flutter/material.dart';
import 'package:taskflow/core/constants/app_strings.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/inputs/app_text_field.dart';

final class PasswordField extends StatelessWidget {
  const PasswordField({
    required this.obscureText,
    required this.onToggleVisibility,
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: AppStrings.loginPasswordLabel,
      hintText: AppStrings.loginPasswordHint,
      errorText: errorText,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.lock_outline_rounded,
      onChanged: onChanged,
      validator: Validators.password,
      suffixIcon: IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
      ),
    );
  }
}
