import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/route_info.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/route_info_card.dart';
import 'package:medigo_mobile/widgets/travel_mode_selector.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    this.routeInfo,
    required this.selectedTravelMode,
    required this.onTravelModeChanged,
    required this.onDismissed,
    this.onBookNow,
  });

  final Doctor doctor;
  final RouteInfo? routeInfo;
  final TravelMode selectedTravelMode;
  final ValueChanged<TravelMode> onTravelModeChanged;
  final VoidCallback onDismissed;
  final VoidCallback? onBookNow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Dismissible(
        key: Key(doctor.id),
        direction: DismissDirection.down,
        onDismissed: (_) => onDismissed(),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.highlight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: doctor.profileImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              doctor.profileImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty,
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Fee: £${doctor.fee.toInt()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${doctor.estimatedTime} min',
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Route Information Section
              if (routeInfo != null) ...[
                const SizedBox(height: 16),
                RouteInfoCard(routeInfo: routeInfo!),
              ],
              // Travel Mode Selector
              const SizedBox(height: 12),
              TravelModeSelector(
                selectedMode: selectedTravelMode,
                onModeChanged: onTravelModeChanged,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBookNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
