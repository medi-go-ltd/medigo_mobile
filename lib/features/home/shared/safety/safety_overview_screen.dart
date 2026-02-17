import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/features/home/shared/safety/emergency_assistance_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/trusted_contacts_screen.dart';

/// Safety at a glance: tips + quick links (Uber-style safety hub / medical app overview).
class SafetyOverviewScreen extends StatelessWidget {
  const SafetyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Safety Overview',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your safety matters',
                    style: AppTypography.pageTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the tools below to stay safe during home visits. Set up trusted contacts and know how to reach emergency help.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick access',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _OverviewTile(
              icon: Icons.emergency_outlined,
              title: 'Emergency Assistance',
              subtitle: 'Call emergency services and share location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmergencyAssistanceScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _OverviewTile(
              icon: Icons.people_outline,
              title: 'Trusted Contacts',
              subtitle: 'Manage who receives your visit details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TrustedContactsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Safety tips',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const _TipCard(
              number: 1,
              text: 'Turn on "Share visit with trusted contacts" so someone knows when and where you\'re visiting.',
            ),
            const SizedBox(height: 8),
            const _TipCard(
              number: 2,
              text: 'Add at least one trusted contact in Safety Check-up so we can share your visit details if you enable it.',
            ),
            const SizedBox(height: 8),
            const _TipCard(
              number: 3,
              text: 'If you feel unsafe at any time, leave the location and call emergency services. You can use Emergency Assistance for one-tap dial.',
            ),
            const SizedBox(height: 8),
            const _TipCard(
              number: 4,
              text: 'Enable check-in reminders in Location Alerts so you get periodic prompts during a visit; if you don\'t respond, contacts can be notified.',
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
