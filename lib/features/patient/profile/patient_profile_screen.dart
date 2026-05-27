import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/verification_status.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('No profile information available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.highlight,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      user.fullName,
                      style: AppTypography.pageTitle.copyWith(fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: _VerificationChip(status: user.verificationStatus),
                  ),
                  const SizedBox(height: 32),
                  _ProfileField(label: 'Email', value: user.email),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Phone',
                    value: user.phoneNumber ?? 'Not provided',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile editing will be available in a future update.',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySecondary.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _VerificationChip extends StatelessWidget {
  const _VerificationChip({required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      VerificationStatus.approved => ('Verified', AppColors.primary),
      VerificationStatus.rejected => ('Verification declined', Colors.red),
      VerificationStatus.pending => ('Verification pending', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
