import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/shared/set_radius_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:provider/provider.dart';

class SetRadiusButton extends StatelessWidget {
  const SetRadiusButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DoctorHomeViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.radiusKm > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text.rich(
                  TextSpan(
                    text: 'Current radius: ',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                    children: [
                      TextSpan(
                        text: '${viewModel.radiusKm.round()} km',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SetRadiusScreen(
                    initialRadius: viewModel.radiusKm,
                    initialIsAvailable: viewModel.isOnline,
                    onSave: (radius, setAvailable) {
                      viewModel.setRadius(radius);
                      if (setAvailable) viewModel.setOnline(true);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Set Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
