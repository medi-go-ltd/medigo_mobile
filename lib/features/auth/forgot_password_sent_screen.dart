import 'package:flutter/material.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/app_header.dart';

class ForgotPasswordSentScreen extends StatelessWidget {
  const ForgotPasswordSentScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 28),
              Icon(
                Icons.mark_email_read_outlined,
                size: 72,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 24),
              const Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: AppTypography.pageTitle,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'If an account exists for $email, you will receive password reset instructions shortly.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.resetPassword,
                          arguments: ResetPasswordArguments(email: email),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: AppTypography.button,
                      ),
                      child: const Text('Enter reset code'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                          (route) =>
                              route.settings.name == AppRoutes.login ||
                              route.isFirst,
                        );
                      },
                      child: Text(
                        'Back to login',
                        style: AppTypography.link.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
