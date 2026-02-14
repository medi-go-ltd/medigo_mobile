import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.useContainerStyle = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool useContainerStyle;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: useContainerStyle ? 48 : 64,
          color: useContainerStyle
              ? AppColors.textSecondary
              : AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTypography.bodySecondary.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(fontSize: 14),
          ),
        ],
      ],
    );

    if (useContainerStyle) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.highlight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: content),
      );
    }

    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: content),
    );
  }
}
