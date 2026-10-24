import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/profile/complete_patient_profile_screen.dart';
import 'package:medigo_mobile/models/verification_status.dart';
import 'package:medigo_mobile/services/profile_completion_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/date_utils.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  String? _dobDisplay;
  Map<String, dynamic>? _deferred;
  bool _incomplete = false;
  bool _loadingExtras = true;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    final user = context.read<AuthViewModel>().user;
    final dobIso = await ProfileCompletionService.getDateOfBirth();
    final deferred = await ProfileCompletionService.getDeferredProfile();
    final incomplete = await ProfileCompletionService.isProfileIncomplete(user);
    if (!mounted) return;

    String? dobDisplay;
    if (dobIso != null) {
      final parsed = DateTime.tryParse(dobIso);
      if (parsed != null) dobDisplay = UkDateUtils.formatUk(parsed);
    }

    setState(() {
      _dobDisplay = dobDisplay;
      _deferred = deferred;
      _incomplete = incomplete;
      _loadingExtras = false;
    });
  }

  Future<void> _openEditor() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CompletePatientProfileScreen(isEditing: true),
      ),
    );
    if (saved == true && mounted) {
      await _loadExtras();
    }
  }

  ImageProvider? _avatarImage(String? profileImageUrl, String? localPath) {
    if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty) {
      if (profileImageUrl.startsWith('http')) {
        return NetworkImage(profileImageUrl);
      }
      final file = File(profileImageUrl);
      if (file.existsSync()) return FileImage(file);
    }
    if (localPath != null && localPath.trim().isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) return FileImage(file);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final localPhoto = _deferred?['localProfileImagePath'] as String?;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        actions: [
          if (user != null)
            TextButton(
              onPressed: _openEditor,
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No profile information available'))
          : _loadingExtras
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.highlight,
                          backgroundImage: _avatarImage(
                            user.profileImageUrl,
                            localPhoto,
                          ),
                          child: _avatarImage(
                                    user.profileImageUrl,
                                    localPhoto,
                                  ) ==
                                  null
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
                        child: _VerificationChip(
                          status: user.verificationStatus,
                        ),
                      ),
                      if (_incomplete) ...[
                        const SizedBox(height: 20),
                        _IncompleteBanner(onEdit: _openEditor),
                      ],
                      const SizedBox(height: 28),
                      const _SectionLabel('Account'),
                      const SizedBox(height: 12),
                      _ProfileField(label: 'Email', value: user.email),
                      const SizedBox(height: 14),
                      _ProfileField(
                        label: 'Phone',
                        value: user.phoneNumber?.trim().isNotEmpty == true
                            ? user.phoneNumber!
                            : 'Not provided',
                      ),
                      const SizedBox(height: 28),
                      const _SectionLabel('Personal'),
                      const SizedBox(height: 12),
                      _ProfileField(
                        label: 'Date of birth',
                        value: _dobDisplay ?? 'Not provided',
                      ),
                      const SizedBox(height: 14),
                      _ProfileField(
                        label: 'Gender',
                        value: user.gender?.trim().isNotEmpty == true
                            ? user.gender!
                            : 'Not provided',
                      ),
                      if (_deferred != null) ...[
                        const SizedBox(height: 28),
                        const _SectionLabel('Health preferences'),
                        const SizedBox(height: 12),
                        _ProfileField(
                          label: 'Medical notes',
                          value: _medicalSummary(_deferred!),
                        ),
                        const SizedBox(height: 14),
                        _ProfileField(
                          label: 'Same-gender doctor preference',
                          value: (_deferred!['sameGenderDoctorPreference']
                                      as bool? ??
                                  false)
                              ? 'Yes'
                              : 'No',
                        ),
                      ],
                      const SizedBox(height: 28),
                      OutlinedButton(
                        onPressed: _openEditor,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _incomplete ? 'Complete profile' : 'Edit profile',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _medicalSummary(Map<String, dynamic> deferred) {
    final flags = <String>[];
    if (deferred['highBloodPressure'] == true) flags.add('High blood pressure');
    if (deferred['diabetes'] == true) flags.add('Diabetes');
    if (deferred['heartDisease'] == true) flags.add('Heart disease');
    if (deferred['asthma'] == true) flags.add('Asthma');
    if (deferred['allergies'] == true) {
      final details = (deferred['allergyDetails'] as String?)?.trim();
      flags.add(
        details != null && details.isNotEmpty
            ? 'Allergies ($details)'
            : 'Allergies',
      );
    }
    final meds = (deferred['currentMedications'] as String?)?.trim();
    if (meds != null && meds.isNotEmpty) flags.add('Medications: $meds');
    final notes = (deferred['additionalNotes'] as String?)?.trim();
    if (notes != null && notes.isNotEmpty) flags.add(notes);
    if (flags.isEmpty) return 'No conditions recorded';
    return flags.join(' · ');
  }
}

class _IncompleteBanner extends StatelessWidget {
  const _IncompleteBanner({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.highlight.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your profile is incomplete. Add phone, date of birth, and health details.',
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
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
            height: 1.35,
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
