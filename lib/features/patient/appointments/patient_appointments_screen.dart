import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/patient/widgets/patient_booking_card.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientBookingViewModel>();
    final active = [
      ...vm.pendingBookings,
      ...vm.activeBookings,
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings', style: AppTypography.pageTitle),
          const SizedBox(height: 8),
          const Text(
            'Active and pending appointments',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: active.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.calendar_today_outlined,
                    title: 'No active bookings',
                    subtitle: 'Book a doctor from the Home tab to get started.',
                  )
                : ListView.builder(
                    itemCount: active.length,
                    itemBuilder: (context, index) {
                      final booking = active[index];
                      return PatientBookingCard(
                        booking: booking,
                        trailing: _etaBadge(booking),
                        onTap: () => _openBooking(context, booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget? _etaBadge(PatientBooking booking) {
    if (booking.doctorEtaMinutes == null || booking.doctorEtaMinutes == 0) {
      return null;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${booking.doctorEtaMinutes} min',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _openBooking(BuildContext context, PatientBooking booking) {
    if (booking.status == PatientBookingStatus.pending) {
      Navigator.of(context).pushNamed(
        AppRoutes.patientWaiting,
        arguments: booking.id,
      );
    } else if (booking.status == PatientBookingStatus.accepted ||
        booking.status == PatientBookingStatus.enRoute ||
        booking.status == PatientBookingStatus.inProgress) {
      Navigator.of(context).pushNamed(
        AppRoutes.patientActiveVisit,
        arguments: booking.id,
      );
    }
  }
}
