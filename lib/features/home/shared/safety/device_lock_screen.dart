import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/services/safety_preferences_service.dart';

/// Medical app standard: PIN or biometric lock to secure the app.
class DeviceLockScreen extends StatefulWidget {
  const DeviceLockScreen({super.key});

  @override
  State<DeviceLockScreen> createState() => _DeviceLockScreenState();
}

class _DeviceLockScreenState extends State<DeviceLockScreen> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await SafetyPreferencesService.getDeviceLockEnabled();
    if (mounted) {
      setState(() {
        _enabled = value;
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
          'Device Lock',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
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
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Require a PIN or biometric (fingerprint / face) to open Medigo. This helps protect your health and visit data if someone else has access to your device.',
                            style: AppTypography.body.copyWith(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App lock',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _enabled
                                    ? 'You\'ll need to unlock when opening the app'
                                    : 'Off — open app without PIN or biometric',
                                style: AppTypography.bodySecondary.copyWith(
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          onChanged: (v) async {
                            final messenger = ScaffoldMessenger.of(context);
                            await SafetyPreferencesService.setDeviceLockEnabled(v);
                            if (mounted) setState(() => _enabled = v);
                            if (mounted && v) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'App lock is on. For full protection, set a PIN in your device settings. Biometric unlock can be added in a future update.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoHighlight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.info, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'For full PIN or biometric lock, use your device\'s built-in security (Settings → Security). This option records your preference; actual lock can be enforced in a future app update.',
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
