import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/patient_navigation.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/view_models/email_verification_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailVerificationViewModel(
        authViewModel: context.read<AuthViewModel>(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AppHeader(),
                  const SizedBox(height: 28),
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 72,
                    color: AppColors.primary.withValues(alpha: 0.9),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: AppTypography.pageTitle,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'We sent a 6-digit code to ${widget.email}. Enter it below to continue.',
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
                    child: Consumer<EmailVerificationViewModel>(
                      builder: (context, viewModel, _) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                controller: _codeController,
                                focusNode: _codeFocusNode,
                                label: 'Verification code',
                                hintText: '6-digit code',
                                icon: Icons.vpn_key_outlined,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(viewModel),
                                validator: (value) {
                                  final code = value?.trim() ?? '';
                                  if (code.isEmpty) {
                                    return 'Verification code is required';
                                  }
                                  if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                                    return 'Enter the 6-digit code from your email';
                                  }
                                  return null;
                                },
                              ),
                              if (viewModel.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  viewModel.errorMessage!,
                                  style: AppTypography.body.copyWith(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              if (viewModel.successMessage != null &&
                                  !viewModel.isVerifyLoading) ...[
                                const SizedBox(height: 12),
                                Text(
                                  viewModel.successMessage!,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: viewModel.isVerifyLoading
                                    ? null
                                    : () => _submit(viewModel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.surface,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  textStyle: AppTypography.button,
                                ),
                                child: viewModel.isVerifyLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.surface,
                                        ),
                                      )
                                    : const Text('Verify email'),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: viewModel.isResendLoading
                                    ? null
                                    : () => _resend(viewModel),
                                child: Text(
                                  viewModel.isResendLoading
                                      ? 'Sending…'
                                      : 'Resend code',
                                  style: AppTypography.link.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(EmailVerificationViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await viewModel.verifyEmail(
      email: widget.email,
      code: _codeController.text,
    );
    if (!mounted) return;
    if (success) {
      await navigateAfterAuth(
        context,
        authViewModel: context.read<AuthViewModel>(),
      );
    }
  }

  Future<void> _resend(EmailVerificationViewModel viewModel) async {
    final ok = await viewModel.resendCode(email: widget.email);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.successMessage ??
                'If an account exists, a new code has been sent.',
          ),
        ),
      );
    }
  }
}
