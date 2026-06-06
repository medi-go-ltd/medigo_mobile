import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/constants/app_branding.dart';
import 'package:medigo_mobile/models/user_role.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserRole? _selectedRole;

  void _onRoleSelected(UserRole role, VoidCallback? onTap) {
    setState(() {
      _selectedRole = role;
    });
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: AppColors.surface,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).padding.bottom,
                left: 24.0,
                right: 24.0,
              ),
              child: Column(
                children: [
                  _buildLogo(),
                  const Text(kAppDisplayName, style: AppTypography.heroTitle),
                  const SizedBox(height: 20),
                  const Text('Welcome', style: AppTypography.heroSubtitle),
                  const SizedBox(height: 20),
                  _buildSignInButton(
                    role: UserRole.doctor,
                    label: 'Sign in as Doctor',
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.login,
                        arguments: const LoginArguments(role: UserRole.doctor),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSignInButton(
                    role: UserRole.patient,
                    label: 'Sign in as Patient',
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.login,
                        arguments: const LoginArguments(role: UserRole.patient),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        child: Image.asset(
          'assets/images/app-logo.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required UserRole role,
    required String label,
    VoidCallback? onTap,
  }) {
    final bool isActive = _selectedRole == role;
    final String assetPath = role == UserRole.doctor
        ? 'assets/images/doctor.png'
        : 'assets/images/image.png';

    return InkWell(
      onTap: () => _onRoleSelected(role, onTap),
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.highlight : AppColors.surface,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Image.asset(assetPath, width: 96, height: 96, fit: BoxFit.contain),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  fontSize: 26,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1 : 0,
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
