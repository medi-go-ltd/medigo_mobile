import 'package:medigo_mobile/models/review.dart';

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
  final String? bio;
  final int? yearsOfExperience;
  final String? gmcNumber;
  final List<String> languages;
  final String? feeIncludes;
  final List<Review> reviews;

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
    this.bio,
    this.yearsOfExperience,
    this.gmcNumber,
    this.languages = const [],
    this.feeIncludes,
    this.reviews = const [],
  });

  String get fullName => 'Dr. $firstName $lastName';

  Doctor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? specialty,
    double? fee,
    String? profileImageUrl,
    double? rating,
    int? reviewCount,
    Location? location,
    int? estimatedTime,
    String? bio,
    int? yearsOfExperience,
    String? gmcNumber,
    List<String>? languages,
    String? feeIncludes,
    List<Review>? reviews,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      specialty: specialty ?? this.specialty,
      fee: fee ?? this.fee,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      bio: bio ?? this.bio,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      gmcNumber: gmcNumber ?? this.gmcNumber,
      languages: languages ?? this.languages,
      feeIncludes: feeIncludes ?? this.feeIncludes,
      reviews: reviews ?? this.reviews,
    );
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final reviewsJson = json['reviews'] as List<dynamic>?;
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
      bio: json['bio'] as String?,
      yearsOfExperience:
          json['yearsOfExperience'] as int? ??
          json['years_of_experience'] as int?,
      gmcNumber:
          json['gmcNumber'] as String? ?? json['gmc_number'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      feeIncludes:
          json['feeIncludes'] as String? ?? json['fee_includes'] as String?,
      reviews: reviewsJson
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'gmcNumber': gmcNumber,
      'languages': languages,
      'feeIncludes': feeIncludes,
      'reviews': reviews.map((r) => r.toJson()).toList(),
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
