import 'package:flutter/material.dart';
import 'package:medigo_mobile/features/home/shared/safety/trusted_contacts_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety_checkup_screen.dart';
import 'package:medigo_mobile/features/patient/profile/patient_profile_screen.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class PatientHomeHeader extends StatelessWidget {
  const PatientHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userName = authViewModel.user?.fullName ?? 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.surface,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
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
                    size: 28,
                    color: AppColors.textPrimary,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Account and settings',
            button: true,
            child: IconButton(
              onPressed: () => _showAccountMenu(context),
              icon: const Icon(
                Icons.more_vert,
                size: 28,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
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
                    builder: (_) => const PatientProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Trusted contacts'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrustedContactsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety_outlined),
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
                await context.read<AuthViewModel>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.welcome,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
