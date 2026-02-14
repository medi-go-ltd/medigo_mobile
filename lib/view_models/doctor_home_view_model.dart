import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/booking.dart';
import 'package:medigo_mobile/models/booking_request.dart';
import 'package:medigo_mobile/models/doctor_profile.dart';
import 'package:medigo_mobile/models/payment_transaction.dart';

/// One data point for earnings-over-time charts (e.g. per day).
class DayEarnings {
  final DateTime date;
  final double amount;
  const DayEarnings(this.date, this.amount);
}

/// Filter for payment history period.
enum PaymentHistoryPeriod { all, thisMonth, last3Months }

class DoctorHomeViewModel extends ChangeNotifier {
  double _radiusKm = 15;
  bool _isOnline = true;

  DoctorProfile _profile = DoctorProfile(
    firstName: 'James',
    lastName: 'Smith',
    email: 'james.smith@example.com',
    phoneNumber: '+44 7123 456789',
    address: '10 Medical Centre, London',
    consultationFee: 75,
    callOutFee: 25,
    radiusKm: 15,
  );

  final List<Booking> _activeBookings = [];
  final List<Booking> _pastBookings = [
    Booking(
      id: 'b-1',
      patientName: 'Sarah Mitchell',
      patientLocation: '5 Elm Road, London',
      reasonForVisit: 'General check-up',
      earnings: 75,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: BookingStatus.completed,
    ),
    Booking(
      id: 'b-2',
      patientName: 'Robert Clarke',
      patientLocation: '12 Park Lane, London',
      reasonForVisit: 'Follow-up consultation',
      earnings: 100,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: BookingStatus.completed,
    ),
  ];
  final List<PaymentTransaction> _paymentHistory = [
    PaymentTransaction(
      id: 'tx-1',
      patientName: 'Sarah Mitchell',
      amount: 75,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Consultation',
    ),
    PaymentTransaction(
      id: 'tx-2',
      patientName: 'Robert Clarke',
      amount: 100,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Consultation + Call-out',
    ),
  ];

  final List<BookingRequest> _liveRequests = [
    BookingRequest(
      id: 'req-1',
      patientName: 'Emma Wilson',
      patientLocation: '23 Oak Street, London SW4 2PX',
      reasonForVisit: 'Headache and fever – urgent consultation requested',
      estimatedEarnings: 85.00,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    BookingRequest(
      id: 'req-2',
      patientName: 'Michael Brown',
      patientLocation: '15 Maple Avenue, London SE1 8AB',
      reasonForVisit: 'Follow-up check for previous respiratory issue',
      estimatedEarnings: 75.00,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  double get radiusKm => _radiusKm;
  bool get isOnline => _isOnline;
  DoctorProfile get profile => _profile;
  List<BookingRequest> get liveRequests => List.unmodifiable(_liveRequests);
  List<Booking> get activeBookings => List.unmodifiable(_activeBookings);
  List<Booking> get pastBookings => List.unmodifiable(_pastBookings);
  List<PaymentTransaction> get paymentHistory => List.unmodifiable(_paymentHistory);

  double get totalEarnings => _paymentHistory.fold(0, (sum, t) => sum + t.amount);

  /// Sum of earnings from active (confirmed) bookings.
  double get upcomingEarnings =>
      _activeBookings.fold(0.0, (sum, b) => sum + b.earnings);

  /// Earnings grouped by day in [start, end] (inclusive). One entry per day; amount 0 if none.
  List<DayEarnings> earningsByDay(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final days = <DateTime, double>{};
    for (var d = startDay;
        !d.isAfter(endDay);
        d = d.add(const Duration(days: 1))) {
      days[d] = 0;
    }
    for (final t in _paymentHistory) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      if (!day.isBefore(startDay) && !day.isAfter(endDay)) {
        days[day] = (days[day] ?? 0) + t.amount;
      }
    }
    final sorted = days.keys.toList()..sort();
    return sorted.map((d) => DayEarnings(d, days[d]!)).toList();
  }

  /// Earnings grouped by description (e.g. "Consultation", "Consultation + Call-out").
  Map<String, double> get earningsByDescription {
    final map = <String, double>{};
    for (final t in _paymentHistory) {
      map[t.description] = (map[t.description] ?? 0) + t.amount;
    }
    return map;
  }

  /// Average earnings per day over the last [n] days (from payment history).
  double averageDailyEarningsLastNDays(int n) {
    if (n <= 0) return 0;
    final end = DateTime.now();
    final start = end.subtract(Duration(days: n));
    final byDay = earningsByDay(start, end);
    final total = byDay.fold(0.0, (s, e) => s + e.amount);
    return total / n;
  }

  /// Simple projection: average daily * remaining days in current week (today included).
  double get projectedEarningsThisWeek {
    final avg = averageDailyEarningsLastNDays(7);
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final daysLeftInWeek = 8 - weekday; // including today
    return avg * daysLeftInWeek.clamp(0, 7);
  }

  /// Payment history filtered by period.
  List<PaymentTransaction> paymentHistoryFiltered(PaymentHistoryPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case PaymentHistoryPeriod.all:
        return List.from(_paymentHistory);
      case PaymentHistoryPeriod.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        return _paymentHistory.where((t) => !t.date.isBefore(start)).toList();
      case PaymentHistoryPeriod.last3Months:
        final start = today.subtract(const Duration(days: 90));
        return _paymentHistory.where((t) => !t.date.isBefore(start)).toList();
    }
  }

  /// Total of filtered payment history (for summary line).
  double totalEarningsInFiltered(PaymentHistoryPeriod period) {
    return paymentHistoryFiltered(period).fold(0.0, (s, t) => s + t.amount);
  }

  void setRadius(double km) {
    _radiusKm = km;
    _profile = _profile.copyWith(radiusKm: km);
    notifyListeners();
  }

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  void acceptBooking(String id) {
    final req = _liveRequests.firstWhere((r) => r.id == id);
    _liveRequests.removeWhere((r) => r.id == id);
    _activeBookings.add(Booking(
      id: req.id,
      patientName: req.patientName,
      patientLocation: req.patientLocation,
      reasonForVisit: req.reasonForVisit,
      earnings: req.estimatedEarnings,
      date: req.requestedAt,
      status: BookingStatus.active,
    ));
    notifyListeners();
  }

  void declineBooking(String id) {
    _liveRequests.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void completeBooking(String id) {
    final b = _activeBookings.firstWhere((x) => x.id == id);
    _activeBookings.removeWhere((x) => x.id == id);
    _pastBookings.insert(0, Booking(
      id: b.id,
      patientName: b.patientName,
      patientLocation: b.patientLocation,
      reasonForVisit: b.reasonForVisit,
      earnings: b.earnings,
      date: DateTime.now(),
      status: BookingStatus.completed,
    ));
    _paymentHistory.insert(0, PaymentTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      patientName: b.patientName,
      amount: b.earnings,
      date: DateTime.now(),
      description: 'Consultation',
    ));
    notifyListeners();
  }

  void updateProfile(DoctorProfile profile) {
    _profile = profile;
    _radiusKm = profile.radiusKm;
    notifyListeners();
  }
}
