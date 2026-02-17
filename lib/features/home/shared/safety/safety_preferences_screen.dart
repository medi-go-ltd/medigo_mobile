import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/services/safety_preferences_service.dart';

/// Uber-style + medical app: central toggles for safety tools.
class SafetyPreferencesScreen extends StatefulWidget {
  const SafetyPreferencesScreen({super.key});

  @override
  State<SafetyPreferencesScreen> createState() => _SafetyPreferencesScreenState();
}

class _SafetyPreferencesScreenState extends State<SafetyPreferencesScreen> {
  bool _shareTripWithContacts = true;
  bool _locationAlertsEnabled = true;
  bool _deviceLockEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final share = await SafetyPreferencesService.getShareTripWithContacts();
    final location = await SafetyPreferencesService.getLocationAlertsEnabled();
    final lock = await SafetyPreferencesService.getDeviceLockEnabled();
    if (mounted) {
      setState(() {
        _shareTripWithContacts = share;
        _locationAlertsEnabled = location;
        _deviceLockEnabled = lock;
        _loading = false;
      });
    }
  }

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
          'Safety Preferences',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose which safety features are on during visits. You can change these anytime.',
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SwitchTile(
                    icon: Icons.people_outline,
                    title: 'Share visit with trusted contacts',
                    subtitle: 'Automatically share visit details with your trusted contacts when you start a visit.',
                    value: _shareTripWithContacts,
                    onChanged: (v) async {
                      await SafetyPreferencesService.setShareTripWithContacts(v);
                      if (mounted) setState(() => _shareTripWithContacts = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SwitchTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location check-in alerts',
                    subtitle: 'Get reminders to check in during visits so your contacts know you\'re safe.',
                    value: _locationAlertsEnabled,
                    onChanged: (v) async {
                      await SafetyPreferencesService.setLocationAlertsEnabled(v);
                      if (mounted) setState(() => _locationAlertsEnabled = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SwitchTile(
                    icon: Icons.lock_outline,
                    title: 'Require PIN or biometric to open app',
                    subtitle: 'Add an extra layer of security. You\'ll need to unlock the app each time you open it.',
                    value: _deviceLockEnabled,
                    onChanged: (v) async {
                      await SafetyPreferencesService.setDeviceLockEnabled(v);
                      if (mounted) setState(() => _deviceLockEnabled = v);
                    },
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoHighlight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.info, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'These settings apply to home visits. For emergencies, use Emergency Assistance from the Safety Check-up menu.',
                            style: AppTypography.bodySecondary.copyWith(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
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
                const SizedBox(height: 4),
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
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
