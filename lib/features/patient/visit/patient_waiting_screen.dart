import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:provider/provider.dart';

class PatientWaitingScreen extends StatelessWidget {
  const PatientWaitingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientBookingViewModel>();
    final booking = vm.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => vm.activeBooking!,
    );

    if (booking.status == PatientBookingStatus.accepted ||
        booking.status == PatientBookingStatus.enRoute ||
        booking.status == PatientBookingStatus.inProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.patientActiveVisit,
            arguments: bookingId,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Waiting for Doctor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: AppColors.highlight,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            const Text(
              'Booking Pending',
              style: AppTypography.pageTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your request has been sent to ${booking.doctor.fullName}. '
              'You will be notified when they respond.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildStatusCard(booking),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil(
                (route) => route.settings.name == AppRoutes.home || route.isFirst,
              ),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(PatientBooking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _row('Doctor', booking.doctor.fullName),
          _row('Status', booking.statusLabel),
          _row('Amount', '£${booking.amount.toInt()}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySecondary),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }
}
