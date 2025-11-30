import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/app_back_button.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.showBackButton = true, this.onBackPressed});

  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBackButton)
            Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(onPressed: onBackPressed),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/app-logo.png', width: 70, height: 70),
              Text(
                'MediGo',
                style: AppTypography.pageTitle.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
