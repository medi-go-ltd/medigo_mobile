import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

/// Gradient divider line used below doctor screen AppBars.
class AppBarGradientDivider extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarGradientDivider({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(1.5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.5),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
