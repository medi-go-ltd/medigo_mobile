import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.tooltip = 'Back'});

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: AppColors.textPrimary,
      ),
      tooltip: tooltip,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
