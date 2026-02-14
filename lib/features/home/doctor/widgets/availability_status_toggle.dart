import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:provider/provider.dart';

class AvailabilityStatusToggle extends StatelessWidget {
  const AvailabilityStatusToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorHomeViewModel>();
    final isOnline = viewModel.isOnline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: AppTypography.bodySecondary.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: _AvailabilitySegment(
                  label: 'Online',
                  isSelected: isOnline,
                  isFirst: true,
                  onTap: () => viewModel.setOnline(true),
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: _AvailabilitySegment(
                  label: 'Offline',
                  isSelected: !isOnline,
                  isFirst: false,
                  onTap: () => viewModel.setOnline(false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailabilitySegment extends StatelessWidget {
  const _AvailabilitySegment({
    required this.label,
    required this.isSelected,
    required this.isFirst,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: isFirst
              ? const BorderRadius.horizontal(left: Radius.circular(8))
              : const BorderRadius.horizontal(right: Radius.circular(8)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
