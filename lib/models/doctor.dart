class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final double fee;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final Location location;
  final int estimatedTime;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.fee,
    this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.estimatedTime,
  });

  String get fullName => 'Dr. $firstName $lastName';

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      firstName:
          json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName:
          json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      specialty: json['specialty'] as String,
      fee: (json['fee'] as num).toDouble(),
      profileImageUrl:
          json['profileImageUrl'] as String? ??
          json['profile_image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:
          json['reviewCount'] as int? ?? json['review_count'] as int? ?? 0,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      estimatedTime:
          json['estimatedTime'] as int? ?? json['estimated_time'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'specialty': specialty,
      'fee': fee,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location.toJson(),
      'estimatedTime': estimatedTime,
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String? address;

  Location({required this.latitude, required this.longitude, this.address});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }
}
