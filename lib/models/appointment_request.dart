class AppointmentRequest {
  final String id;
  final String patientName;
  final String patientLocation;
  final String reasonForVisit;
  final double estimatedEarnings;
  final DateTime requestedAt;
  final String? patientPhone;

  AppointmentRequest({
    required this.id,
    required this.patientName,
    required this.patientLocation,
    required this.reasonForVisit,
    required this.estimatedEarnings,
    required this.requestedAt,
    this.patientPhone,
  });

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id: json['id'] as String,
      patientName: json['patientName'] as String? ?? json['patient_name'] as String? ?? '',
      patientLocation: json['patientLocation'] as String? ?? json['patient_location'] as String? ?? '',
      reasonForVisit: json['reasonForVisit'] as String? ?? json['reason_for_visit'] as String? ?? '',
      estimatedEarnings: (json['estimatedEarnings'] as num?)?.toDouble() ?? (json['estimated_earnings'] as num?)?.toDouble() ?? 0,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'] as String)
          : json['requested_at'] != null
              ? DateTime.parse(json['requested_at'] as String)
              : DateTime.now(),
      patientPhone: json['patientPhone'] as String? ?? json['patient_phone'] as String?,
    );
  }
}
