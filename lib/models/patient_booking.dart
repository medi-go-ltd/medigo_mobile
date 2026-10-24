import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/family_member.dart';

enum PatientBookingStatus {
  draft,
  pending,
  accepted,
  declined,
  enRoute,
  inProgress,
  completed,
}

enum PaymentMethodType { debitCard, creditCard, applePay, googlePay, paypal }

enum IssueSeverity { mild, moderate, severe, verySevere }

extension IssueSeverityLabel on IssueSeverity {
  String get label {
    switch (this) {
      case IssueSeverity.mild:
        return 'Mild';
      case IssueSeverity.moderate:
        return 'Moderate';
      case IssueSeverity.severe:
        return 'Severe';
      case IssueSeverity.verySevere:
        return 'Very Severe';
    }
  }

  String get emoji {
    switch (this) {
      case IssueSeverity.mild:
        return '🙂';
      case IssueSeverity.moderate:
        return '😐';
      case IssueSeverity.severe:
        return '😣';
      case IssueSeverity.verySevere:
        return '😫';
    }
  }
}

class TriageAnswers {
  final bool severeChestPain;
  final bool difficultyBreathing;
  final bool severePain;
  final bool lossOfConsciousness;

  const TriageAnswers({
    this.severeChestPain = false,
    this.difficultyBreathing = false,
    this.severePain = false,
    this.lossOfConsciousness = false,
  });

  bool get isUrgent =>
      severeChestPain ||
      difficultyBreathing ||
      severePain ||
      lossOfConsciousness;

  TriageAnswers copyWith({
    bool? severeChestPain,
    bool? difficultyBreathing,
    bool? severePain,
    bool? lossOfConsciousness,
  }) {
    return TriageAnswers(
      severeChestPain: severeChestPain ?? this.severeChestPain,
      difficultyBreathing: difficultyBreathing ?? this.difficultyBreathing,
      severePain: severePain ?? this.severePain,
      lossOfConsciousness: lossOfConsciousness ?? this.lossOfConsciousness,
    );
  }
}

/// One person being seen during a visit, with their own screening answers.
class BookingPatient {
  /// Null when the patient is the account holder.
  final FamilyMember? member;
  final TriageAnswers triage;
  final List<String> bodyAreas;
  final IssueSeverity? issueSeverity;
  final String description;

  const BookingPatient({
    this.member,
    this.triage = const TriageAnswers(),
    this.bodyAreas = const [],
    this.issueSeverity,
    this.description = '',
  });

  bool get isAccountHolder => member == null;

  /// Stable key for selection: the member id, or 'self'.
  String get key => member?.id ?? 'self';

  /// e.g. "Myself" or "Leo Smith (Child, 4 yrs)".
  String get label {
    final m = member;
    if (m == null) return 'Myself';
    return '${m.fullName} (${m.relationship.label}, ${m.ageLabel})';
  }

  BookingPatient copyWith({
    TriageAnswers? triage,
    List<String>? bodyAreas,
    IssueSeverity? issueSeverity,
    String? description,
  }) {
    return BookingPatient(
      member: member,
      triage: triage ?? this.triage,
      bodyAreas: bodyAreas ?? this.bodyAreas,
      issueSeverity: issueSeverity ?? this.issueSeverity,
      description: description ?? this.description,
    );
  }
}

class PatientBooking {
  /// Each patient after the first is charged this fraction of the fee.
  static const additionalPatientRate = 0.5;

  static double totalFee(double baseFee, int patientCount) {
    if (patientCount <= 1) return baseFee;
    return baseFee + baseFee * additionalPatientRate * (patientCount - 1);
  }

  final String id;
  final Doctor doctor;
  final List<BookingPatient> patients;
  final PaymentMethodType paymentMethod;
  final double amount;
  final PatientBookingStatus status;
  final DateTime createdAt;
  final int? doctorEtaMinutes;
  final int? rating;
  final String? review;
  final bool isNearestDoctor;

  PatientBooking({
    required this.id,
    required this.doctor,
    this.patients = const [BookingPatient()],
    this.paymentMethod = PaymentMethodType.debitCard,
    required this.amount,
    this.status = PatientBookingStatus.draft,
    required this.createdAt,
    this.doctorEtaMinutes,
    this.rating,
    this.review,
    this.isNearestDoctor = false,
  });

  PatientBooking copyWith({
    String? id,
    Doctor? doctor,
    List<BookingPatient>? patients,
    PaymentMethodType? paymentMethod,
    double? amount,
    PatientBookingStatus? status,
    DateTime? createdAt,
    int? doctorEtaMinutes,
    int? rating,
    String? review,
    bool? isNearestDoctor,
  }) {
    return PatientBooking(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      patients: patients ?? this.patients,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      doctorEtaMinutes: doctorEtaMinutes ?? this.doctorEtaMinutes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isNearestDoctor: isNearestDoctor ?? this.isNearestDoctor,
    );
  }

  bool get isUrgent => patients.any((p) => p.triage.isUrgent);

  /// e.g. "Myself" or "Myself, Leo Smith (Child, 4 yrs)".
  String get appointmentForLabel => patients.map((p) => p.label).join(', ');

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.paypal:
        return 'PayPal';
    }
  }

  String get statusLabel {
    switch (status) {
      case PatientBookingStatus.draft:
        return 'Draft';
      case PatientBookingStatus.pending:
        return 'Pending';
      case PatientBookingStatus.accepted:
        return 'Accepted';
      case PatientBookingStatus.declined:
        return 'Declined';
      case PatientBookingStatus.enRoute:
        return 'Doctor En Route';
      case PatientBookingStatus.inProgress:
        return 'In Progress';
      case PatientBookingStatus.completed:
        return 'Completed';
    }
  }
}

class PaymentRecord {
  final String id;
  final String bookingId;
  final String doctorName;
  final double amount;
  final PaymentMethodType method;
  final DateTime date;
  final String description;

  PaymentRecord({
    required this.id,
    required this.bookingId,
    required this.doctorName,
    required this.amount,
    required this.method,
    required this.date,
    required this.description,
  });

  String get methodLabel {
    switch (method) {
      case PaymentMethodType.debitCard:
        return 'Debit Card';
      case PaymentMethodType.creditCard:
        return 'Credit Card';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.paypal:
        return 'PayPal';
    }
  }
}
