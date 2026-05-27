import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/appointment.dart';
import 'package:medigo_mobile/models/appointment_flag.dart';
import 'package:medigo_mobile/models/appointment_request.dart';
import 'package:medigo_mobile/models/doctor_profile.dart';
import 'package:medigo_mobile/models/earnings_transaction.dart';
import 'package:medigo_mobile/models/visit_notes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DayEarnings {
  final DateTime date;
  final double amount;
  const DayEarnings(this.date, this.amount);
}

enum EarningsHistoryPeriod { all, thisMonth, last3Months }

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

  final List<Appointment> _activeAppointments = [];
  final List<Appointment> _pastAppointments = [
    Appointment(
      id: 'b-1',
      patientName: 'Sarah Mitchell',
      patientLocation: '5 Elm Road, London',
      reasonForVisit: 'General check-up',
      earnings: 75,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: AppointmentStatus.completed,
    ),
    Appointment(
      id: 'b-2',
      patientName: 'Robert Clarke',
      patientLocation: '12 Park Lane, London',
      reasonForVisit: 'Follow-up consultation',
      earnings: 100,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: AppointmentStatus.completed,
    ),
  ];
  final List<EarningsTransaction> _earningsHistory = [
    EarningsTransaction(
      id: 'tx-1',
      patientName: 'Sarah Mitchell',
      amount: 75,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Consultation',
    ),
    EarningsTransaction(
      id: 'tx-2',
      patientName: 'Robert Clarke',
      amount: 100,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Consultation + Call-out',
    ),
  ];

  final Map<String, VisitNotes> _visitNotes = {};
  final Map<String, VisitNotes> _completedVisitNotes = {};

  final List<AppointmentRequest> _liveRequests = [
    AppointmentRequest(
      id: 'req-1',
      patientName: 'Emma Wilson',
      patientLocation: '23 Oak Street, London SW4 2PX',
      reasonForVisit: 'Headache and fever – urgent consultation requested',
      estimatedEarnings: 85.00,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AppointmentRequest(
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
  List<AppointmentRequest> get liveRequests => List.unmodifiable(_liveRequests);
  List<Appointment> get activeAppointments =>
      List.unmodifiable(_activeAppointments);
  List<Appointment> get pastAppointments =>
      List.unmodifiable(_pastAppointments);
  List<EarningsTransaction> get earningsHistory =>
      List.unmodifiable(_earningsHistory);

  double get totalEarnings =>
      _earningsHistory.fold(0, (sum, t) => sum + t.amount);

  double get upcomingEarnings =>
      _activeAppointments.fold(0.0, (sum, a) => sum + a.earnings);

  List<DayEarnings> earningsByDay(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final days = <DateTime, double>{};
    for (
      var d = startDay;
      !d.isAfter(endDay);
      d = d.add(const Duration(days: 1))
    ) {
      days[d] = 0;
    }
    for (final t in _earningsHistory) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      if (!day.isBefore(startDay) && !day.isAfter(endDay)) {
        days[day] = (days[day] ?? 0) + t.amount;
      }
    }
    final sorted = days.keys.toList()..sort();
    return sorted.map((d) => DayEarnings(d, days[d]!)).toList();
  }

  Map<String, double> get earningsByDescription {
    final map = <String, double>{};
    for (final t in _earningsHistory) {
      map[t.description] = (map[t.description] ?? 0) + t.amount;
    }
    return map;
  }

  double averageDailyEarningsLastNDays(int n) {
    if (n <= 0) return 0;
    final end = DateTime.now();
    final start = end.subtract(Duration(days: n));
    final byDay = earningsByDay(start, end);
    final total = byDay.fold(0.0, (s, e) => s + e.amount);
    return total / n;
  }

  double get projectedEarningsThisWeek {
    final avg = averageDailyEarningsLastNDays(7);
    final now = DateTime.now();
    final weekday = now.weekday;
    final daysLeftInWeek = 8 - weekday;
    return avg * daysLeftInWeek.clamp(0, 7);
  }

  List<EarningsTransaction> earningsHistoryFiltered(
    EarningsHistoryPeriod period,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case EarningsHistoryPeriod.all:
        return List.from(_earningsHistory);
      case EarningsHistoryPeriod.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        return _earningsHistory.where((t) => !t.date.isBefore(start)).toList();
      case EarningsHistoryPeriod.last3Months:
        final start = today.subtract(const Duration(days: 90));
        return _earningsHistory.where((t) => !t.date.isBefore(start)).toList();
    }
  }

  double totalEarningsInFiltered(EarningsHistoryPeriod period) {
    return earningsHistoryFiltered(period).fold(0.0, (s, t) => s + t.amount);
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

  void acceptAppointment(String id) {
    final req = _liveRequests.firstWhere((r) => r.id == id);
    _liveRequests.removeWhere((r) => r.id == id);
    _activeAppointments.add(
      Appointment(
        id: req.id,
        patientName: req.patientName,
        patientLocation: req.patientLocation,
        reasonForVisit: req.reasonForVisit,
        earnings: req.estimatedEarnings,
        date: req.requestedAt,
        status: AppointmentStatus.active,
      ),
    );
    notifyListeners();
  }

  void declineAppointment(String id) {
    _liveRequests.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void addLiveRequest(AppointmentRequest request) {
    _liveRequests.insert(0, request);
    notifyListeners();
  }

  VisitNotes getVisitNotes(String appointmentId) {
    return _visitNotes[appointmentId] ?? const VisitNotes();
  }

  VisitNotes? getCompletedVisitNotes(String appointmentId) {
    return _completedVisitNotes[appointmentId];
  }

  Future<String?> addScreenshotToNotes(
    String appointmentId,
    String sourcePath,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final visitDir = Directory(
        p.join(dir.path, 'visit_notes', appointmentId),
      );
      if (!await visitDir.exists()) await visitDir.create(recursive: true);
      final name =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
      final destPath = p.join(visitDir.path, name);
      await File(sourcePath).copy(destPath);
      final notes = getVisitNotes(appointmentId);
      final updated = notes.copyWith(
        screenshotPaths: [...notes.screenshotPaths, destPath],
      );
      _visitNotes[appointmentId] = updated;
      notifyListeners();
      return destPath;
    } catch (_) {
      return null;
    }
  }

  void updateManualNotes(String appointmentId, String text) {
    final notes = getVisitNotes(appointmentId);
    _visitNotes[appointmentId] = notes.copyWith(manualNotes: text);
    notifyListeners();
  }

  void setAiNotes(String appointmentId, String? text) {
    final notes = getVisitNotes(appointmentId);
    _visitNotes[appointmentId] = notes.copyWith(aiNotes: text);
    notifyListeners();
  }

  void removeScreenshot(String appointmentId, String path) {
    final notes = getVisitNotes(appointmentId);
    final updated = notes.copyWith(
      screenshotPaths: notes.screenshotPaths.where((e) => e != path).toList(),
    );
    _visitNotes[appointmentId] = updated;
    try {
      File(path).deleteSync();
    } catch (_) {}
    notifyListeners();
  }

  void addFlag(String appointmentId, AppointmentFlag flag) {
    final notes = getVisitNotes(appointmentId);
    _visitNotes[appointmentId] = notes.copyWith(flags: [...notes.flags, flag]);
    notifyListeners();
  }

  void completeAppointment(String id) {
    final a = _activeAppointments.firstWhere((x) => x.id == id);
    final notes = _visitNotes[id];
    if (notes != null && notes.hasContent) {
      _completedVisitNotes[id] = notes;
      _visitNotes.remove(id);
    }
    _activeAppointments.removeWhere((x) => x.id == id);
    _pastAppointments.insert(
      0,
      Appointment(
        id: a.id,
        patientName: a.patientName,
        patientLocation: a.patientLocation,
        reasonForVisit: a.reasonForVisit,
        earnings: a.earnings,
        date: DateTime.now(),
        status: AppointmentStatus.completed,
      ),
    );
    _earningsHistory.insert(
      0,
      EarningsTransaction(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        patientName: a.patientName,
        amount: a.earnings,
        date: DateTime.now(),
        description: 'Consultation',
      ),
    );
    notifyListeners();
  }

  void updateProfile(DoctorProfile profile) {
    _profile = profile;
    _radiusKm = profile.radiusKm;
    notifyListeners();
  }
}
