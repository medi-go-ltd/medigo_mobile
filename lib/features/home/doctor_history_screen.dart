import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor_profile_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/booking_card.dart';
import 'package:provider/provider.dart';

class DoctorHistoryScreen extends StatelessWidget {
  const DoctorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final pastBookings = viewModel.pastBookings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 24,
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your completed visits',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 20),
              if (pastBookings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.highlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'No completed visits yet',
                          style: AppTypography.bodySecondary.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...pastBookings.map((b) => BookingCard(booking: b)),
            ],
          ),
        ),
      ),
    );
  }
}
