import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class PatientBookingCard extends StatelessWidget {
  const PatientBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.trailing,
  });

  final PatientBooking booking;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.highlight,
                child: Text(
                  booking.doctor.firstName[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.doctor.fullName,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.doctor.specialty,
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: _statusColor(booking.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null) ...[
                if (trailing != null) const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(PatientBookingStatus status) {
    switch (status) {
      case PatientBookingStatus.pending:
        return AppColors.warning;
      case PatientBookingStatus.declined:
        return Colors.red;
      case PatientBookingStatus.accepted:
      case PatientBookingStatus.enRoute:
      case PatientBookingStatus.inProgress:
        return AppColors.primary;
      case PatientBookingStatus.completed:
        return Colors.green.shade700;
      case PatientBookingStatus.draft:
        return AppColors.textSecondary;
    }
  }
}
