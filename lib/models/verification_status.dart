enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus parse(String? value) {
    if (value == null) return VerificationStatus.pending;
    switch (value.toLowerCase()) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }
}
