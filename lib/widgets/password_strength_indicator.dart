import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/password_requirement_item.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  bool get hasUpperCase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowerCase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements',
            style: AppTypography.bodySecondary.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          PasswordRequirementItem(
            label: 'Uppercase letter',
            isValid: hasUpperCase,
            icon: Icons.arrow_upward,
          ),
          const SizedBox(height: 8),
          PasswordRequirementItem(
            label: 'Lowercase letter',
            isValid: hasLowerCase,
            icon: Icons.arrow_downward,
          ),
          const SizedBox(height: 8),
          PasswordRequirementItem(
            label: 'Number',
            isValid: hasNumber,
            icon: Icons.numbers,
          ),
          const SizedBox(height: 8),
          PasswordRequirementItem(
            label: 'Special character',
            isValid: hasSpecialChar,
            icon: Icons.star,
          ),
        ],
      ),
    );
  }
}
