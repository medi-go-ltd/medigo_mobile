import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_profile_screen.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/app_bar_gradient_divider.dart';

class DoctorScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DoctorScreenAppBar({
    super.key,
    required this.title,
    this.showSettings = true,
    this.leading,
    this.bottom,
  });

  final String title;
  final bool showSettings;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 1.5;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: leading,
      automaticallyImplyLeading: leading != null,
      titleSpacing: leading != null ? 0 : 24,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: showSettings
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorProfileScreen(),
                    ),
                  ),
                ),
              ),
            ]
          : null,
      bottom:
          bottom ??
          const PreferredSize(
            preferredSize: Size.fromHeight(1.5),
            child: AppBarGradientDivider(),
          ),
    );
  }
}
