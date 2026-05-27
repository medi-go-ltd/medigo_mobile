import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medigo_mobile/features/patient/chat/patient_chat_screen.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/patient_booking_view_model.dart';
import 'package:medigo_mobile/view_models/patient_home_view_model.dart';
import 'package:provider/provider.dart';

class PatientActiveVisitScreen extends StatelessWidget {
  const PatientActiveVisitScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientBookingViewModel>();
    final booking = vm.bookings.firstWhere((b) => b.id == bookingId);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(booking.doctor.fullName),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildStatusBanner(booking),
            const SizedBox(height: 20),
            _VisitMapCard(booking: booking),
            const SizedBox(height: 20),
            _MessagingCard(
              doctorName: booking.doctor.fullName,
              bookingId: booking.id,
            ),
            const Spacer(),
            if (booking.status == PatientBookingStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: () {
                    vm.completeVisit(bookingId);
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.patientRating,
                      arguments: bookingId,
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
                  child: const Text('Visit Complete (Demo)'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(PatientBooking booking) {
    IconData icon;
    Color color;
    String message;

    switch (booking.status) {
      case PatientBookingStatus.accepted:
        icon = Icons.check_circle_outline;
        color = AppColors.earnings;
        message = 'Doctor accepted your booking';
      case PatientBookingStatus.enRoute:
        icon = Icons.directions_car;
        color = AppColors.info;
        message = 'Doctor is en route to your location';
      case PatientBookingStatus.inProgress:
        icon = Icons.medical_services_outlined;
        color = AppColors.primary;
        message = 'Visit in progress';
      default:
        icon = Icons.hourglass_empty;
        color = AppColors.textSecondary;
        message = booking.statusLabel;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitMapCard extends StatelessWidget {
  const _VisitMapCard({required this.booking});

  final PatientBooking booking;

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<PatientHomeViewModel>();
    final doctor = booking.doctor;

    final patientLocation = homeVm.userLocation;
    final doctorLatLng = LatLng(
      doctor.location.latitude,
      doctor.location.longitude,
    );
    final patientLatLng = patientLocation != null
        ? LatLng(patientLocation.latitude, patientLocation.longitude)
        : doctorLatLng;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('doctor'),
        position: doctorLatLng,
        infoWindow: InfoWindow(title: doctor.fullName),
      ),
      if (patientLocation != null)
        Marker(
          markerId: const MarkerId('patient'),
          position: patientLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your location'),
        ),
    };

    final cameraTarget = LatLng(
      (doctorLatLng.latitude + patientLatLng.latitude) / 2,
      (doctorLatLng.longitude + patientLatLng.longitude) / 2,
    );

    final showEta = booking.doctorEtaMinutes != null &&
        booking.status == PatientBookingStatus.enRoute;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 220,
          child: Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: cameraTarget,
                zoom: 13,
              ),
              markers: markers,
              myLocationEnabled: patientLocation != null,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: false,
            ),
            if (showEta)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _EtaBanner(minutes: booking.doctorEtaMinutes!),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

class _EtaBanner extends StatelessWidget {
  const _EtaBanner({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'ETA: $minutes min',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagingCard extends StatelessWidget {
  const _MessagingCard({
    required this.doctorName,
    required this.bookingId,
  });

  final String doctorName;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientChatScreen(
                doctorName: doctorName,
                bookingId: bookingId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.highlight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In-App Messaging',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chat securely with your doctor',
                      style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
