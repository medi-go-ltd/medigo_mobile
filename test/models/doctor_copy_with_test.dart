import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_mobile/models/doctor.dart';
import 'package:medigo_mobile/models/review.dart';

void main() {
  test('copyWith preserves profile fields when updating ETA', () {
    final doctor = Doctor(
      id: 'doc-1',
      firstName: 'Sarah',
      lastName: 'Johnson',
      specialty: 'Pediatrics',
      fee: 120,
      rating: 4.8,
      reviewCount: 10,
      location: Location(latitude: 1, longitude: 2, address: 'Clinic'),
      estimatedTime: 12,
      bio: 'Experienced paediatrician',
      yearsOfExperience: 10,
      gmcNumber: '7400000',
      languages: const ['English'],
      feeIncludes: 'Home visit',
      reviews: const [
        Review(
          name: 'Priya',
          text: 'Great',
          rating: 5,
          date: '1 Jan 2026',
        ),
      ],
    );

    final updated = doctor.copyWith(estimatedTime: 7);

    expect(updated.estimatedTime, 7);
    expect(updated.bio, 'Experienced paediatrician');
    expect(updated.reviews, hasLength(1));
    expect(updated.gmcNumber, '7400000');
    expect(updated.languages, ['English']);
    expect(updated.feeIncludes, 'Home visit');
    expect(updated.location.address, 'Clinic');
  });
}
