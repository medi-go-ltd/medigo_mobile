import 'package:flutter/material.dart';
import 'package:medigo_mobile/constants/registration_assets.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:medigo_mobile/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum _RegistrationStepStatus { completed, current, pending }

class _RegistrationStep {
  const _RegistrationStep({
    required this.label,
    required this.status,
  });

  final String label;
  final _RegistrationStepStatus status;
}

class PatientRegistrationSuccessScreen extends StatelessWidget {
  const PatientRegistrationSuccessScreen({super.key});

  static const _supportEmail = 'hello@medi-go.co.uk';

  static const _steps = [
    _RegistrationStep(
      label: 'Registration submitted',
      status: _RegistrationStepStatus.completed,
    ),
    _RegistrationStep(
      label: 'Documents received',
      status: _RegistrationStepStatus.completed,
    ),
    _RegistrationStep(
      label: 'Verification in progress',
      status: _RegistrationStepStatus.current,
    ),
    _RegistrationStep(
      label: 'Approval email',
      status: _RegistrationStepStatus.pending,
    ),
    _RegistrationStep(
      label: 'Account activated',
      status: _RegistrationStepStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(showBackButton: false),
              const SizedBox(height: 28),
              Text(
                'Thank You for Registering!',
                textAlign: TextAlign.center,
                style: AppTypography.pageTitle.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 20),
              _buildEstimatedReviewBanner(),
              const SizedBox(height: 20),
              _buildTimelineCard(),
              const SizedBox(height: 28),
              _buildPrimaryButton(context),
              const SizedBox(height: 12),
              _buildSignOutButton(context),
              const SizedBox(height: 20),
              _buildSupportFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final bodyStyle = AppTypography.body.copyWith(
      color: AppColors.textSecondary,
      height: 1.45,
      fontSize: 15,
    );

    return Column(
      children: [
        Text(
          'Your application has been received.',
          textAlign: TextAlign.center,
          style: bodyStyle,
        ),
        const SizedBox(height: 12),
        Text(
          'We’re reviewing your information and will notify you\n'
          'by email once verification is complete.',
          textAlign: TextAlign.center,
          style: bodyStyle,
        ),
      ],
    );
  }

  Widget _buildEstimatedReviewBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            RegistrationAssets.clock,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                  fontSize: 15,
                ),
                children: const [
                  TextSpan(text: 'Estimated review time '),
                  TextSpan(
                    text: '1 – 3 business days',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next?',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_steps.length, (index) {
            return _TimelineStepRow(
              step: _steps[index],
              isLast: index == _steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.patientVerificationPending,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _leftIconButtonContent(
          icon: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              AppColors.surface,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              RegistrationAssets.home,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          label: 'View Application Status',
          labelStyle: AppTypography.button.copyWith(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _signOut(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _leftIconButtonContent(
          icon: Image.asset(
            RegistrationAssets.signOut,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          label: 'Sign Out',
          labelStyle: AppTypography.button.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSupportFooter(BuildContext context) {
    return InkWell(
      onTap: _launchSupportEmail,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              RegistrationAssets.support,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  style: AppTypography.bodySecondary.copyWith(fontSize: 14),
                  children: const [
                    TextSpan(text: 'Questions? '),
                    TextSpan(
                      text: _supportEmail,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.welcome,
        (route) => false,
      );
    }
  }

  Widget _leftIconButtonContent({
    required Widget icon,
    required String label,
    required TextStyle labelStyle,
  }) {
    const horizontalInset = 20.0;
    const iconSlot = 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Row(
        children: [
          SizedBox(width: iconSlot, child: icon),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ),
          const SizedBox(width: iconSlot),
        ],
      ),
    );
  }

  Future<void> _launchSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: const {
        'subject': 'Medi Go registration question',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({
    required this.step,
    required this.isLast,
  });

  final _RegistrationStep step;
  final bool isLast;

  static const _iconSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final isCompleted = step.status == _RegistrationStepStatus.completed;
    final isCurrent = step.status == _RegistrationStepStatus.current;

    final labelColor = isCompleted || isCurrent
        ? (isCurrent ? AppColors.primary : AppColors.textPrimary)
        : AppColors.textSecondary.withValues(alpha: 0.55);

    final labelWeight = isCurrent ? FontWeight.w600 : FontWeight.w500;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 12 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _iconSize,
            child: Column(
              children: [
                _buildStepIcon(),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 16,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isCompleted
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : AppColors.border,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: isLast ? 4 : 8),
              child: Text(
                step.label,
                style: AppTypography.body.copyWith(
                  color: labelColor,
                  fontWeight: labelWeight,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon() {
    final asset = switch (step.status) {
      _RegistrationStepStatus.completed => _iconForCompleted(step.label),
      _RegistrationStepStatus.current => RegistrationAssets.timelineCurrent,
      _RegistrationStepStatus.pending => RegistrationAssets.timelinePending,
    };

    return Image.asset(
      asset,
      width: _iconSize,
      height: _iconSize,
      fit: BoxFit.contain,
    );
  }

  String _iconForCompleted(String label) {
    if (label == 'Approval email') {
      return RegistrationAssets.approvalEmailComplete;
    }
    if (label == 'Account activated') {
      return RegistrationAssets.accountActivatedComplete;
    }
    return RegistrationAssets.timelineComplete;
  }

}
