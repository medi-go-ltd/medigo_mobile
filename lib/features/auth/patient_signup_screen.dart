import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/patient_registration_request.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/services/profile_completion_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/patient_navigation.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/view_models/signup_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/password_field.dart';
import 'package:medigo_mobile/widgets/social_sign_in_buttons.dart';
import 'package:provider/provider.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeader(),
                  const SizedBox(height: 20),
                  const Text(
                    'Create patient account',
                    textAlign: TextAlign.center,
                    style: AppTypography.pageTitle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A few details to get started. You can add more later.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  SocialSignInButtons(
                    role: UserRole.patient,
                    onSuccess: _afterAuthSuccess,
                    onError: _showError,
                  ),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _firstName,
                    focusNode: _firstNameFocus,
                    label: 'First Name',
                    hintText: 'First name',
                    icon: Icons.person_outline,
                    required: true,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: ValidationUtils.validateFirstName,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_lastNameFocus),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lastName,
                    focusNode: _lastNameFocus,
                    label: 'Last Name',
                    hintText: 'Last name',
                    icon: Icons.badge_outlined,
                    required: true,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: ValidationUtils.validateLastName,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocus),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _email,
                    focusNode: _emailFocus,
                    label: 'Email',
                    hintText: 'Email',
                    icon: Icons.mail_outline,
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: ValidationUtils.validateEmail,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocus),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _password,
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.done,
                    validator: ValidationUtils.validatePassword,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 28),
                  Consumer<SignupViewModel>(
                    builder: (context, viewModel, _) {
                      return ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.6),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.surface,
                                  ),
                                ),
                              )
                            : const Text('Create Account'),
                      );
                    },
                  ),
                  Consumer<SignupViewModel>(
                    builder: (context, viewModel, _) {
                      if (!viewModel.hasError) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          viewModel.errorMessage ?? 'Registration failed',
                          style: AppTypography.bodySecondary.copyWith(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or sign up with email',
            style: AppTypography.bodySecondary.copyWith(fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = PatientRegistrationRequest(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );

    final vm = context.read<SignupViewModel>();
    final success = await vm.registerPatient(request);
    if (!mounted) return;
    if (success) {
      await _afterAuthSuccess();
    } else if (vm.hasError) {
      _showError(vm.errorMessage ?? 'Registration failed');
    }
  }

  Future<void> _afterAuthSuccess() async {
    await ProfileCompletionService.markJustSignedUp();
    if (!mounted) return;
    await navigateAfterAuth(
      context,
      authViewModel: context.read<AuthViewModel>(),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
