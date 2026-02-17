enum FlagReason {
  abuse,
  addressIssue,
  safetyConcern,
  other,
}

extension FlagReasonX on FlagReason {
  String get label {
    switch (this) {
      case FlagReason.abuse:
        return 'Abuse or harassment';
      case FlagReason.addressIssue:
        return 'Address / location issue';
      case FlagReason.safetyConcern:
        return 'Safety concern';
      case FlagReason.other:
        return 'Other';
    }
  }
}

class AppointmentFlag {
  final FlagReason reason;
  final String description;
  final DateTime flaggedAt;
  final bool isAddressFlag;

  const AppointmentFlag({
    required this.reason,
    required this.description,
    required this.flaggedAt,
    this.isAddressFlag = false,
  });
}
