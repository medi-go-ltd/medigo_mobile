import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class ProjectedEarningsCard extends StatelessWidget {
  const ProjectedEarningsCard({
    super.key,
    required this.projected,
    required this.avgDaily,
  });

  final double projected;
  final double avgDaily;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
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
                  'Projected this week',
                  style: AppTypography.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Based on last 7 days (~£${avgDaily.toStringAsFixed(0)}/day)',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '~£${projected.toStringAsFixed(0)}',
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
