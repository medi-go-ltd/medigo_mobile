import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/appointment_request.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/patient_booking.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/body_diagram_widget.dart';

class PatientBookingViewModel extends ChangeNotifier {
  PatientBookingViewModel({DoctorHomeViewModel? doctorHomeViewModel})
    : _doctorHomeViewModel = doctorHomeViewModel;

  final DoctorHomeViewModel? _doctorHomeViewModel;

  PatientBooking? _draft;
  PatientBooking? _activeBooking;
  final List<PatientBooking> _bookings = [];
  final List<PaymentRecord> _payments = [];
  Timer? _statusTimer;

  PatientBooking? get draft => _draft;
  PatientBooking? get activeBooking => _activeBooking;
  List<PatientBooking> get bookings => List.unmodifiable(_bookings);
  List<PatientBooking> get pendingBookings => _bookings
      .where((b) => b.status == PatientBookingStatus.pending)
      .toList();
  List<PatientBooking> get activeBookings => _bookings
      .where(
        (b) =>
            b.status == PatientBookingStatus.accepted ||
            b.status == PatientBookingStatus.enRoute ||
            b.status == PatientBookingStatus.inProgress,
      )
      .toList();
  List<PatientBooking> get completedBookings => _bookings
      .where((b) => b.status == PatientBookingStatus.completed)
      .toList();
  List<PaymentRecord> get payments => List.unmodifiable(_payments);

  void startBooking(Doctor doctor, {bool isNearestDoctor = false}) {
    _draft = PatientBooking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      doctor: doctor,
      amount: doctor.fee.toDouble(),
      createdAt: DateTime.now(),
      isNearestDoctor: isNearestDoctor,
    );
    notifyListeners();
  }

  void updateDraft({
    BookingFor? bookingFor,
    String? otherPersonName,
    TriageAnswers? triage,
    List<String>? bodyAreas,
    IssueSeverity? issueSeverity,
    String? description,
    PaymentMethodType? paymentMethod,
  }) {
    if (_draft == null) return;
    _draft = _draft!.copyWith(
      bookingFor: bookingFor,
      otherPersonName: otherPersonName,
      triage: triage,
      bodyAreas: bodyAreas,
      issueSeverity: issueSeverity,
      description: description,
      paymentMethod: paymentMethod,
    );
    notifyListeners();
  }

  void clearDraft() {
    _draft = null;
    notifyListeners();
  }

  Future<PatientBooking?> confirmBooking({
    required String patientName,
    required String patientLocation,
  }) async {
    if (_draft == null) return null;

    final booking = _draft!.copyWith(
      status: PatientBookingStatus.pending,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, booking);
    _activeBooking = booking;
    _draft = null;

    final request = AppointmentRequest(
      id: booking.id,
      patientName: patientName,
      patientLocation: patientLocation,
      reasonForVisit: _buildReasonForVisit(booking),
      estimatedEarnings: booking.amount,
      requestedAt: booking.createdAt,
    );
    _doctorHomeViewModel?.addLiveRequest(request);

    notifyListeners();
    _simulateDoctorResponse(booking.id);
    return booking;
  }

  String _buildReasonForVisit(PatientBooking booking) {
    final parts = <String>[];
    if (booking.bodyAreas.isNotEmpty) {
      parts.add('Areas: ${BodyDiagramWidget.formatAreas(booking.bodyAreas)}');
    }
    if (booking.issueSeverity != null) {
      parts.add('Severity: ${booking.issueSeverity!.label}');
    } else if (booking.description.isNotEmpty) {
      parts.add(booking.description);
    }
    if (booking.triage.isUrgent) parts.add('URGENT triage flagged');
    return parts.isEmpty ? 'Consultation requested' : parts.join(' – ');
  }

  void _simulateDoctorResponse(String bookingId) {
    _statusTimer?.cancel();
    _statusTimer = Timer(const Duration(seconds: 4), () {
      _updateBookingStatus(
        bookingId,
        PatientBookingStatus.accepted,
        doctorEtaMinutes: 12,
      );
      _statusTimer = Timer(const Duration(seconds: 3), () {
        _updateBookingStatus(
          bookingId,
          PatientBookingStatus.enRoute,
          doctorEtaMinutes: 8,
        );
        _statusTimer = Timer(const Duration(seconds: 5), () {
          _updateBookingStatus(
            bookingId,
            PatientBookingStatus.inProgress,
            doctorEtaMinutes: 0,
          );
          _statusTimer = Timer(const Duration(seconds: 6), () {
            _updateBookingStatus(
              bookingId,
              PatientBookingStatus.completed,
            );
          });
        });
      });
    });
  }

  void _updateBookingStatus(
    String id,
    PatientBookingStatus status, {
    int? doctorEtaMinutes,
  }) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) return;

    _bookings[index] = _bookings[index].copyWith(
      status: status,
      doctorEtaMinutes: doctorEtaMinutes,
    );
    if (_activeBooking?.id == id) {
      _activeBooking = _bookings[index];
    }
    notifyListeners();
  }

  void completeVisit(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    final booking = _bookings[index];
    _bookings[index] = booking.copyWith(
      status: PatientBookingStatus.completed,
    );

    _payments.insert(
      0,
      PaymentRecord(
        id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
        bookingId: booking.id,
        doctorName: booking.doctor.fullName,
        amount: booking.amount,
        method: booking.paymentMethod,
        date: DateTime.now(),
        description: 'Consultation with ${booking.doctor.fullName}',
      ),
    );

    if (_activeBooking?.id == bookingId) {
      _activeBooking = null;
    }
    notifyListeners();
  }

  void submitRating(String bookingId, int rating, {String? review}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    _bookings[index] = _bookings[index].copyWith(
      rating: rating,
      review: review,
    );
    notifyListeners();
  }

  void cancelStatusSimulation() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  /// Seeds a completed booking for demos/tests (e.g. history list).
  void seedCompletedBooking(PatientBooking booking) {
    final completed = booking.copyWith(
      status: PatientBookingStatus.completed,
    );
    _bookings.insert(0, completed);
    notifyListeners();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
