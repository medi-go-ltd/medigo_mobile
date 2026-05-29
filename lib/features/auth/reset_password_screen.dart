import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/view_models/forgot_password_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/password_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.initialToken,
  });

  final String email;
  final String? initialToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _tokenFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    if (widget.initialToken != null) {
      _tokenController.text = widget.initialToken!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _tokenFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                  'Reset password',
                  textAlign: TextAlign.center,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code from your email and choose a new password.',
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
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _tokenController,
                          focusNode: _tokenFocusNode,
                          label: 'Reset code',
                          hintText: 'Paste code from email',
                          icon: Icons.vpn_key_outlined,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                              _passwordFocusNode,
                            );
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Reset code is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          validator: ValidationUtils.validatePassword,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                              _confirmPasswordFocusNode,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          label: 'Confirm password',
                          hintText: 'Confirm password',
                          icon: Icons.lock_outline,
                          obscureText: !_isConfirmPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSubmit(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) => ValidationUtils
                              .validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<ForgotPasswordViewModel>(
                          builder: (context, viewModel, child) {
                            return ElevatedButton(
                              onPressed: viewModel.isResetLoading
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
                              child: viewModel.isResetLoading
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
                                  : const Text('Update password'),
                            );
                          },
                        ),
                        Consumer<ForgotPasswordViewModel>(
                          builder: (context, viewModel, child) {
                            if (viewModel.hasResetError) {
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
                            'Back',
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
    final success = await viewModel.resetPassword(
      email: widget.email,
      token: _tokenController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.successMessage ??
                'Password updated. You can sign in with your new password.',
          ),
        ),
      );
      Navigator.of(context).popUntil(
        (route) =>
            route.settings.name == AppRoutes.login || route.isFirst,
      );
    }
  }
}
