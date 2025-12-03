import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class PasswordRequirementItem extends StatelessWidget {
  const PasswordRequirementItem({
    super.key,
    required this.label,
    required this.isValid,
    required this.icon,
  });

  final String label;
  final bool isValid;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isValid ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isValid
                    ? AppColors.primary.withValues(alpha: value)
                    : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isValid
                    ? Transform.scale(
                        scale: value,
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.surface,
                        ),
                      )
                    : Icon(icon, size: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 13,
                  color: isValid ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(label),
              ),
            ),
          ],
        );
      },
    );
  }
}
