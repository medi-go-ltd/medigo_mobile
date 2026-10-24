class AppointmentRequest {
  final String id;
  final String patientName;
  final String patientLocation;
  final String reasonForVisit;
  final double estimatedEarnings;
  final DateTime requestedAt;
  final String? patientPhone;

  /// e.g. "Child · 4 yrs · Male" when the patient is a family member.
  final String? patientDetails;

  /// Account holder who booked on the patient's behalf.
  final String? bookedBy;

  AppointmentRequest({
    required this.id,
    required this.patientName,
    required this.patientLocation,
    required this.reasonForVisit,
    required this.estimatedEarnings,
    required this.requestedAt,
    this.patientPhone,
    this.patientDetails,
    this.bookedBy,
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
      patientDetails: json['patientDetails'] as String? ?? json['patient_details'] as String?,
      bookedBy: json['bookedBy'] as String? ?? json['booked_by'] as String?,
    );
  }
}
