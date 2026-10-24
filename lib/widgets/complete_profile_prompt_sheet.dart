import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/profile/complete_patient_profile_screen.dart';
import 'package:medigo_mobile/services/profile_completion_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

/// Dismissible bottom sheet prompting patients to finish deferred profile details.
Future<void> showCompleteProfilePrompt(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.of(sheetContext).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Finish your profile',
              style: AppTypography.pageTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add a few details so doctors can prepare for your visit. '
              'You can keep using the app either way.',
              style: AppTypography.bodySecondary.copyWith(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CompletePatientProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Add details'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await ProfileCompletionService.dismissPrompt();
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
              child: Text(
                'Not now',
                style: AppTypography.link.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    },
  );
}
