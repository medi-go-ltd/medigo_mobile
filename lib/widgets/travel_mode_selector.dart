import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/route_info.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class TravelModeSelector extends StatelessWidget {
  const TravelModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final TravelMode selectedMode;
  final ValueChanged<TravelMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Mode:',
          style: AppTypography.bodySecondary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildModeButton(
                TravelMode.driving,
                selectedMode == TravelMode.driving,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                TravelMode.walking,
                selectedMode == TravelMode.walking,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                TravelMode.bicycling,
                selectedMode == TravelMode.bicycling,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                TravelMode.transit,
                selectedMode == TravelMode.transit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(TravelMode mode, bool isSelected) {
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode.icon,
              size: 18,
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              mode.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
