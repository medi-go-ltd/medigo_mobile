import 'package:medigo_mobile/models/review.dart';

class MockReviewsRepository {
  MockReviewsRepository._();

  static final List<Review> mockReviews = [
    const Review(
      name: 'Sarah Mitchell',
      text:
          'Dr. Smith was incredibly professional and thorough. He took the time to explain everything clearly and put me at ease. Highly recommend!',
      rating: 5,
      date: '2 days ago',
    ),
    const Review(
      name: 'John Kelly',
      text:
          'Great bedside manner. The consultation was quick but didn\'t feel rushed. Very knowledgeable doctor.',
      rating: 5,
      date: '1 week ago',
    ),
    const Review(
      name: 'Emma Lewis',
      text:
          'Arrived promptly and was very helpful. Solved my issue effectively.',
      rating: 4,
      date: '2 weeks ago',
    ),
    const Review(
      name: 'David Parker',
      text:
          'Excellent doctor. Took time to listen and address all my concerns. Will definitely book again if needed.',
      rating: 5,
      date: '3 weeks ago',
    ),
    const Review(
      name: 'Michael Brown',
      text: 'Very good experience overall. Professional and courteous.',
      rating: 4,
      date: '1 month ago',
    ),
  ];
}
