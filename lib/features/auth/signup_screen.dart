import 'package:flutter/material.dart';

import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/validation_utils.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:medigo_mobile/widgets/app_text_field.dart';
import 'package:medigo_mobile/widgets/password_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _extraFieldController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _extraFieldFocusNode = FocusNode();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _extraFieldController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _extraFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String roleLabel = widget.role == UserRole.doctor
        ? 'Doctor'
        : 'Patient';

    final String extraFieldLabel = widget.role == UserRole.doctor
        ? 'Medical Registration Number'
        : 'Confirm Password';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppHeader(),
                const SizedBox(height: 32),
                const Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: AppTypography.pageTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a $roleLabel account',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 18,
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
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _firstNameController,
                                focusNode: _firstNameFocusNode,
                                label: 'First Name',
                                hintText: 'First Name',
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_lastNameFocusNode);
                                },
                                validator: ValidationUtils.validateFirstName,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _lastNameController,
                                focusNode: _lastNameFocusNode,
                                label: 'Last Name',
                                hintText: 'Last Name',
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_emailFocusNode);
                                },
                                validator: ValidationUtils.validateLastName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: 'Email',
                          hintText: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocusNode);
                          },
                          validator: ValidationUtils.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        PasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_extraFieldFocusNode);
                          },
                          validator: ValidationUtils.validatePassword,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _extraFieldController,
                          focusNode: _extraFieldFocusNode,
                          label: extraFieldLabel,
                          hintText: extraFieldLabel,
                          icon: widget.role == UserRole.doctor
                              ? Icons.badge_outlined
                              : Icons.lock_outline,
                          keyboardType: widget.role == UserRole.doctor
                              ? TextInputType.text
                              : TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            _handleSignup();
                          },
                          obscureText: widget.role == UserRole.patient,
                          validator: widget.role == UserRole.doctor
                              ? ValidationUtils
                                    .validateMedicalRegistrationNumber
                              : (value) =>
                                    ValidationUtils.validateConfirmPassword(
                                      value,
                                      _passwordController.text,
                                    ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: AppTypography.button,
                          ),
                          child: const Text('Sign Up'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: AppTypography.body,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Log In',
                                style: AppTypography.link,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
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

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Handle signup action
    }
  }
}
