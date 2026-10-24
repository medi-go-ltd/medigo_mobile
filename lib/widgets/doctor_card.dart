import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/route_info.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/utils/location_utils.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    this.routeInfo,
    this.userLocation,
    required this.onDismissed,
    this.onBookNow,
    this.onViewProfile,
  });

  final Doctor doctor;
  final RouteInfo? routeInfo;
  final Location? userLocation;
  final VoidCallback onDismissed;
  final VoidCallback? onBookNow;
  final VoidCallback? onViewProfile;

  String get _distanceLabel {
    if (routeInfo != null) return routeInfo!.distance;
    if (userLocation != null) {
      final km = LocationUtils.distanceToDoctor(userLocation!, doctor);
      final miles = km * 0.621371;
      return '${miles.toStringAsFixed(1)} miles';
    }
    return '—';
  }

  String get _arrivalLabel {
    if (routeInfo != null) return routeInfo!.duration;
    final min = doctor.estimatedTime < 1 ? 1 : doctor.estimatedTime;
    final low = (min - 3).clamp(1, min);
    return '$low–${min + 3} mins';
  }

  String get _feeAndTimeLabel {
    final timePart = routeInfo?.duration ?? '${doctor.estimatedTime} min away';
    return 'Fee: £${doctor.fee.toInt()} • $timePart';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(doctor.id),
      direction: DismissDirection.down,
      onDismissed: (_) => onDismissed(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DoctorProfileRow(
                  doctor: doctor,
                  feeAndTimeLabel: _feeAndTimeLabel,
                ),
                const SizedBox(height: 20),
                _DoctorStatsRow(
                  arrivalLabel: _arrivalLabel,
                  distanceLabel: _distanceLabel,
                  rating: doctor.rating,
                  reviewCount: doctor.reviewCount,
                ),
                const SizedBox(height: 20),
                const _BookingTimelineSection(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewProfile ?? onBookNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
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
}

class _DoctorProfileRow extends StatelessWidget {
  const _DoctorProfileRow({
    required this.doctor,
    required this.feeAndTimeLabel,
  });

  final Doctor doctor;
  final String feeAndTimeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: doctor.profileImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    doctor.profileImageUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.medical_services_outlined,
                  size: 28,
                  color: AppColors.surface,
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                doctor.specialty,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feeAndTimeLabel,
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.earningsHighlight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.earnings.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.earnings,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Available now',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.earnings,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoctorStatsRow extends StatelessWidget {
  const _DoctorStatsRow({
    required this.arrivalLabel,
    required this.distanceLabel,
    required this.rating,
    required this.reviewCount,
  });

  final String arrivalLabel;
  final String distanceLabel;
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.access_time,
              iconColor: AppColors.primary,
              label: 'Est. arrival',
              value: arrivalLabel,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.primary,
              label: 'Distance',
              value: distanceLabel,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.star,
              iconColor: AppColors.time,
              label: 'Rating',
              value: '${rating.toStringAsFixed(1)} ★ ($reviewCount)',
            ),
          ),
          const Expanded(
            child: _StatItem(
              icon: Icons.verified_user_outlined,
              iconColor: AppColors.primary,
              label: 'Verified',
              value: 'GMC • DBS',
              valueFontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueFontSize = 12,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.bodySecondary.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _BookingTimelineSection extends StatelessWidget {
  const _BookingTimelineSection();

  static const _steps = [
    (Icons.assignment_outlined, 'Doctor\naccepts'),
    (Icons.directions_car_outlined, 'Doctor\ntravels'),
    (Icons.notifications_outlined, 'Arrival\nnotification'),
    (Icons.medical_services_outlined, 'Visit\nbegins'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What happens next?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(_steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, 2),
                        painter: _DottedLinePainter(),
                      );
                    },
                  ),
                ),
              );
            }
            final stepIndex = index ~/ 2;
            final (icon, label) = _steps[stepIndex];
            return Expanded(
              child: _TimelineStep(
                stepNumber: stepIndex + 1,
                icon: icon,
                label: label,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.stepNumber,
    required this.icon,
    required this.label,
  });

  final int stepNumber;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.bodySecondary.copyWith(
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
