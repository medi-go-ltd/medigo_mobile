import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class UpcomingEarningsCard extends StatelessWidget {
  const UpcomingEarningsCard({
    super.key,
    required this.amount,
    required this.bookingCount,
  });

  final double amount;
  final int bookingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming earnings',
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$bookingCount confirmed ${bookingCount == 1 ? 'visit' : 'visits'}',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '£${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
