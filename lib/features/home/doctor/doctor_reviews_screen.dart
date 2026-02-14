import 'package:flutter/material.dart';
import 'package:medigo_mobile/repositories/mock_reviews_repository.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/doctor_screen_app_bar.dart';
import 'package:medigo_mobile/widgets/review_card.dart';

class DoctorReviewsScreen extends StatelessWidget {
  const DoctorReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = MockReviewsRepository.mockReviews;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DoctorScreenAppBar(
        title: 'Reviews',
        showSettings: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: reviews.length,
        separatorBuilder: (context, index) => const Divider(height: 32),
        itemBuilder: (context, index) {
          return ReviewCard(review: reviews[index]);
        },
      ),
    );
  }
}
