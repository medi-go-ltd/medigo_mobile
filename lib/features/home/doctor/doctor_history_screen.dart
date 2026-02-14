import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/booking_card.dart';
import 'package:medigo_mobile/widgets/doctor_screen_app_bar.dart';
import 'package:medigo_mobile/widgets/empty_state_widget.dart';
import 'package:provider/provider.dart';

class DoctorHistoryScreen extends StatelessWidget {
  const DoctorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final pastBookings = viewModel.pastBookings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const DoctorScreenAppBar(title: 'History'),
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
                const EmptyStateWidget(
                  icon: Icons.history,
                  title: 'No completed visits yet',
                  useContainerStyle: true,
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
