enum BookingStatus { active, completed }

class Booking {
  final String id;
  final String patientName;
  final String patientLocation;
  final String reasonForVisit;
  final double earnings;
  final DateTime date;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.patientName,
    required this.patientLocation,
    required this.reasonForVisit,
    required this.earnings,
    required this.date,
    required this.status,
  });
}
