import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/route_info.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class RouteInfoCard extends StatelessWidget {
  const RouteInfoCard({super.key, required this.routeInfo});

  final RouteInfo routeInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(routeInfo.mode.icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            routeInfo.mode.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  routeInfo.duration,
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.straighten,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  routeInfo.distance,
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
