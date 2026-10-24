import 'package:flutter/material.dart';
import 'package:medigo_mobile/config/app_config.dart';
import 'package:medigo_mobile/models/social_sign_in_request.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/services/social_auth_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/login_view_model.dart';
import 'package:provider/provider.dart';

/// Google / Apple one-tap buttons for the patient auth path.
class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    super.key,
    required this.role,
    required this.onSuccess,
    required this.onError,
  });

  final UserRole role;
  final Future<void> Function() onSuccess;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) {
    if (role != UserRole.patient) {
      return const SizedBox.shrink();
    }

    return Consumer<LoginViewModel>(
      builder: (context, loginVm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SocialButton(
              label: 'Continue with Google',
              icon: Image.asset(
                'assets/images/google_g.png',
                width: 22,
                height: 22,
                filterQuality: FilterQuality.high,
              ),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              borderColor: AppColors.border,
              loading: loginVm.isLoading,
              onPressed: () => _signIn(context, SocialProvider.google),
            ),
            if (SocialAuthService.isAppleAvailable) ...[
              const SizedBox(height: 12),
              // Apple HIG: black button + white mark reads clearest on light UIs.
              _SocialButton(
                label: 'Continue with Apple',
                icon: const Icon(Icons.apple, size: 22, color: Colors.white),
                backgroundColor: const Color(0xFF000000),
                foregroundColor: Colors.white,
                borderColor: const Color(0xFF000000),
                loading: loginVm.isLoading,
                onPressed: () => _signIn(context, SocialProvider.apple),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _signIn(BuildContext context, SocialProvider provider) async {
    final loginVm = context.read<LoginViewModel>();
    try {
      String idToken;
      String? email;
      String? firstName;
      String? lastName;
      String? nonce;

      if (AppConfig.useMockData) {
        idToken = 'mock-${provider.name}-token';
        email = provider == SocialProvider.google
            ? 'patient.google@example.com'
            : 'patient.apple@example.com';
        firstName = provider == SocialProvider.google ? 'Alex' : 'Sam';
        lastName = 'Patient';
      } else {
        final result = provider == SocialProvider.google
            ? await SocialAuthService.signInWithGoogle()
            : await SocialAuthService.signInWithApple();
        if (result == null) return;
        idToken = result.idToken;
        email = result.email;
        firstName = result.firstName;
        lastName = result.lastName;
        nonce = result.nonce;
      }

      final success = await loginVm.signInWithSocial(
        SocialSignInRequest(
          provider: provider,
          idToken: idToken,
          role: 'patient',
          email: email,
          firstName: firstName,
          lastName: lastName,
          nonce: nonce,
        ),
      );

      if (!context.mounted) return;
      if (success) {
        await onSuccess();
      } else if (loginVm.hasError) {
        onError(loginVm.errorMessage ?? 'Sign-in failed');
      }
    } catch (e) {
      onError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.loading,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final bool loading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.7),
        disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

