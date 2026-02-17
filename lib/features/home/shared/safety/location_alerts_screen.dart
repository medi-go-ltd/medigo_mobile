import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/services/safety_preferences_service.dart';

/// Uber-style: automatic check-in alerts during visits so contacts know you're safe.
class LocationAlertsScreen extends StatefulWidget {
  const LocationAlertsScreen({super.key});

  @override
  State<LocationAlertsScreen> createState() => _LocationAlertsScreenState();
}

class _LocationAlertsScreenState extends State<LocationAlertsScreen> {
  bool _enabled = true;
  int _intervalMinutes = 15;
  bool _loading = true;

  static const List<int> _intervalOptions = [10, 15, 30, 45];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled =
        await SafetyPreferencesService.getLocationAlertsEnabled();
    final interval =
        await SafetyPreferencesService.getCheckInIntervalMinutes();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _intervalMinutes = _intervalOptions.contains(interval)
            ? interval
            : 15;
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
          'Location Alerts',
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
                  Text(
                    'Get reminder check-ins during home visits. If you don\'t check in, your trusted contacts can be notified.',
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 14,
                      height: 1.4,
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check-in reminders',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Receive alerts during an active visit',
                                style: AppTypography.bodySecondary.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          onChanged: (v) async {
                            await SafetyPreferencesService
                                .setLocationAlertsEnabled(v);
                            if (mounted) setState(() => _enabled = v);
                          },
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  if (_enabled) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Remind me every',
                      style: AppTypography.bodySecondary.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _intervalOptions.map((minutes) {
                        final selected = _intervalMinutes == minutes;
                        return ChoiceChip(
                          label: Text('$minutes min'),
                          selected: selected,
                          onSelected: (v) async {
                            if (!v) return;
                            await SafetyPreferencesService
                                .setCheckInIntervalMinutes(minutes);
                            if (mounted) setState(() => _intervalMinutes = minutes);
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                            'When you\'re on a visit, we\'ll remind you to check in at your chosen interval. If you don\'t respond, your trusted contacts may be notified. Add contacts in Trusted Contacts.',
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
