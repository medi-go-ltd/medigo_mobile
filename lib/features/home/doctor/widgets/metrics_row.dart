import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class MetricsRow extends StatelessWidget {
  const MetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Earnings Today',
            value: '£125',
            icon: Icons.attach_money,
            iconColor: AppColors.earnings,
            backgroundColor: AppColors.earningsHighlight,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Online Time',
            value: '4 h 12 m',
            icon: Icons.access_time,
            iconColor: AppColors.time,
            backgroundColor: AppColors.timeHighlight,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Avg. Response',
            value: '7 min',
            icon: Icons.timer_outlined,
            iconColor: AppColors.info,
            backgroundColor: AppColors.infoHighlight,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
