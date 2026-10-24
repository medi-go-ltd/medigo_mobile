enum FamilyRelationship { child, partner, parent, sibling, grandparent, other }

extension FamilyRelationshipLabel on FamilyRelationship {
  String get label {
    switch (this) {
      case FamilyRelationship.child:
        return 'Child';
      case FamilyRelationship.partner:
        return 'Partner';
      case FamilyRelationship.parent:
        return 'Parent';
      case FamilyRelationship.sibling:
        return 'Sibling';
      case FamilyRelationship.grandparent:
        return 'Grandparent';
      case FamilyRelationship.other:
        return 'Other';
    }
  }

  /// Relationships where the person can't plausibly be under 16.
  bool get requiresAdult =>
      this == FamilyRelationship.partner ||
      this == FamilyRelationship.parent ||
      this == FamilyRelationship.grandparent;
}

/// A person the account holder can book visits for.
class FamilyMember {
  /// Under this age a parent or guardian must be present; at or over it the
  /// person consents for themselves.
  static const adultAge = 16;

  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;

  /// 'Female' or 'Male'; drives the body map figure.
  final String sexAtBirth;
  final FamilyRelationship relationship;
  final String? allergies;
  final String? conditions;
  final String? medications;

  const FamilyMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.sexAtBirth,
    required this.relationship,
    this.allergies,
    this.conditions,
    this.medications,
  });

  String get fullName => '$firstName $lastName'.trim();

  int ageOn(DateTime date) {
    var age = date.year - dateOfBirth.year;
    final hadBirthday =
        date.month > dateOfBirth.month ||
        (date.month == dateOfBirth.month && date.day >= dateOfBirth.day);
    if (!hadBirthday) age--;
    return age < 0 ? 0 : age;
  }

  int get age => ageOn(DateTime.now());

  bool get isMinor => age < adultAge;

  String get ageLabel {
    final now = DateTime.now();
    final years = ageOn(now);
    if (years >= 2) return '$years yrs';
    var months =
        (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) months--;
    if (months < 0) months = 0;
    return months == 1 ? '1 month' : '$months months';
  }

  /// e.g. "Child · 4 yrs · Male"
  String get summary => '${relationship.label} · $ageLabel · $sexAtBirth';

  /// Allergies, conditions and medications for the doctor, or null if none.
  String? get healthNotes {
    final parts = <String>[
      if (allergies?.trim().isNotEmpty == true)
        'Allergies: ${allergies!.trim()}',
      if (conditions?.trim().isNotEmpty == true)
        'Conditions: ${conditions!.trim()}',
      if (medications?.trim().isNotEmpty == true)
        'Medications: ${medications!.trim()}',
    ];
    return parts.isEmpty ? null : parts.join('; ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'sexAtBirth': sexAtBirth,
    'relationship': relationship.name,
    'allergies': allergies,
    'conditions': conditions,
    'medications': medications,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      sexAtBirth: json['sexAtBirth'] as String? ?? 'Female',
      relationship: FamilyRelationship.values.firstWhere(
        (r) => r.name == json['relationship'],
        orElse: () => FamilyRelationship.other,
      ),
      allergies: json['allergies'] as String?,
      conditions: json['conditions'] as String?,
      medications: json['medications'] as String?,
    );
  }
}
