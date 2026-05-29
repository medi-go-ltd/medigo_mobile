import 'package:medigo_mobile/models/doctor.dart';

enum PatientBookingStatus {
  draft,
  pending,
  accepted,
  declined,
  enRoute,
  inProgress,
  completed,
}

enum BookingFor { myself, someoneElse }

enum PaymentMethodType {
  debitCard,
  creditCard,
  applePay,
  googlePay,
  paypal,
}

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

class PatientBooking {
  final String id;
  final Doctor doctor;
  final BookingFor bookingFor;
  final String? otherPersonName;
  final TriageAnswers triage;
  final List<String>? _bodyAreas;
  final IssueSeverity? issueSeverity;
  final String description;
  final PaymentMethodType paymentMethod;
  final double amount;
  final PatientBookingStatus status;
  final DateTime createdAt;
  final int? doctorEtaMinutes;
  final int? rating;
  final String? review;
  final bool isNearestDoctor;

  List<String> get bodyAreas => _bodyAreas ?? const [];

  PatientBooking({
    required this.id,
    required this.doctor,
    this.bookingFor = BookingFor.myself,
    this.otherPersonName,
    this.triage = const TriageAnswers(),
    List<String>? bodyAreas,
    this.issueSeverity,
    this.description = '',
    this.paymentMethod = PaymentMethodType.debitCard,
    required this.amount,
    this.status = PatientBookingStatus.draft,
    required this.createdAt,
    this.doctorEtaMinutes,
    this.rating,
    this.review,
    this.isNearestDoctor = false,
  }) : _bodyAreas = bodyAreas ?? const [];

  PatientBooking copyWith({
    String? id,
    Doctor? doctor,
    BookingFor? bookingFor,
    String? otherPersonName,
    TriageAnswers? triage,
    List<String>? bodyAreas,
    IssueSeverity? issueSeverity,
    String? description,
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
      bookingFor: bookingFor ?? this.bookingFor,
      otherPersonName: otherPersonName ?? this.otherPersonName,
      triage: triage ?? this.triage,
      bodyAreas: bodyAreas ?? this.bodyAreas,
      issueSeverity: issueSeverity ?? this.issueSeverity,
      description: description ?? this.description,
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
