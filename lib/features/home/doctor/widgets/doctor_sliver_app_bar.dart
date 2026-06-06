import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/doctor/doctor_profile_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety_checkup_screen.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/constants/app_branding.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class DoctorSliverAppBar extends StatelessWidget {
  const DoctorSliverAppBar({
    super.key,
    required this.isAppBarCollapsed,
    this.expandedHeight = 92,
  });

  final bool isAppBarCollapsed;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final firstName = user?.firstName ?? '';
    final greeting =
        firstName.isNotEmpty ? 'Welcome back, $firstName' : 'Welcome back';

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: isAppBarCollapsed ? 2 : 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isAppBarCollapsed ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !isAppBarCollapsed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/app-logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                const Text(
                  kAppDisplayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.03),
                AppColors.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 100, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to see patients?',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Semantics(
          label: 'Notifications. Unread notifications',
          button: true,
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Open notifications
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade400,
                    border: Border.all(color: AppColors.surface, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Semantics(
            label: 'More options',
            button: true,
            child: IconButton(
              onPressed: () => _showProfileMenu(context),
              icon: const Icon(
                Icons.more_vert,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DoctorProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Safety Check-up'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SafetyCheckupScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                Navigator.pop(ctx);
                final authViewModel = context.read<AuthViewModel>();
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
