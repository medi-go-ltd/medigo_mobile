enum AppointmentStatus { active, completed }

class Appointment {
  final String id;
  final String patientName;
  final String patientLocation;
  final String reasonForVisit;
  final double earnings;
  final DateTime date;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientLocation,
    required this.reasonForVisit,
    required this.earnings,
    required this.date,
    required this.status,
  });
}
