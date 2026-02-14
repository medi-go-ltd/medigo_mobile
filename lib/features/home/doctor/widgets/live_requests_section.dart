import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/widgets/metrics_row.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/booking_request_card.dart';
import 'package:provider/provider.dart';

class LiveRequestsSection extends StatelessWidget {
  const LiveRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final requests = viewModel.liveRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.live_tv_rounded,
              size: 22,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Live Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (requests.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Status will auto-switch to 'On a visit' after accepting.",
          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.highlight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.inbox_outlined, size: 32, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No live requests right now. New requests will appear when you\'re online.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...requests.map(
            (r) => BookingRequestCard(
              request: r,
              onAccept: () => viewModel.acceptBooking(r.id),
              onDecline: () => viewModel.declineBooking(r.id),
            ),
          ),
        const SizedBox(height: 20),
        const MetricsRow(),
      ],
    );
  }
}
