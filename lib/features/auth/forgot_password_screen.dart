import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/view_models/forgot_password_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Text(
                  'Forgot password',
                  textAlign: TextAlign.center,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and we will send reset instructions.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: 'Email',
                          hintText: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSubmit(),
                          validator: ValidationUtils.validateEmail,
                        ),
                        const SizedBox(height: 24),
                        Consumer<ForgotPasswordViewModel>(
                          builder: (context, viewModel, child) {
                            return ElevatedButton(
                              onPressed: viewModel.isRequestLoading
                                  ? null
                                  : _handleSubmit,
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
                                disabledBackgroundColor: AppColors.primary
                                    .withValues(alpha: 0.6),
                              ),
                              child: viewModel.isRequestLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.surface,
                                            ),
                                      ),
                                    )
                                  : const Text('Send reset link'),
                            );
                          },
                        ),
                        Consumer<ForgotPasswordViewModel>(
                          builder: (context, viewModel, child) {
                            if (viewModel.hasRequestError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  viewModel.errorMessage ??
                                      'An error occurred',
                                  style: AppTypography.bodySecondary.copyWith(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final viewModel = context.read<ForgotPasswordViewModel>();
    final success = await viewModel.requestPasswordReset(
      email: _emailController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.forgotPasswordSent,
        arguments: ForgotPasswordSentArguments(
          email: _emailController.text.trim(),
        ),
      );
    }
  }
}
