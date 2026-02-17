class EarningsTransaction {
  final String id;
  final String patientName;
  final double amount;
  final DateTime date;
  final String description;

  EarningsTransaction({
    required this.id,
    required this.patientName,
    required this.amount,
    required this.date,
    required this.description,
  });
}
