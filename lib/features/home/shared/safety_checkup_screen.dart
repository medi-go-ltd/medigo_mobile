import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/features/home/shared/safety/safety_preferences_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/emergency_assistance_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/trusted_contacts_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/device_lock_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/location_alerts_screen.dart';
import 'package:medigo_mobile/features/home/shared/safety/safety_overview_screen.dart';

class SafetyCheckupScreen extends StatefulWidget {
  const SafetyCheckupScreen({super.key});

  @override
  State<SafetyCheckupScreen> createState() => _SafetyCheckupScreenState();
}

class _SafetyCheckupScreenState extends State<SafetyCheckupScreen> {
  static const _defaultStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  // Dark status bar content (clock, network, battery) for visibility on light blue header.
  // statusBarBrightness.light = iOS uses dark content; statusBarIconBrightness.dark = Android dark icons.
  static const _safetyScreenStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const _safetyItems = [
    (
      icon: Icons.settings_outlined,
      title: 'Safety Preferences',
      description: 'Customize your preferred safety tools',
    ),
    (
      icon: Icons.medical_services_outlined,
      title: 'Emergency Assistance',
      description: 'Learn how to quickly reach emergency services',
    ),
    (
      icon: Icons.people_outline,
      title: 'Trusted Contacts',
      description: 'Store trusted contacts to quickly share visit details',
    ),
    (
      icon: Icons.lock_outline,
      title: 'Device Lock',
      description: 'Add a PIN or biometric lock to secure your account',
    ),
    (
      icon: Icons.location_on_outlined,
      title: 'Location Alerts',
      description: 'Receive automatic check-in alerts during visits',
    ),
    (
      icon: Icons.info_outlined,
      title: 'Safety Overview',
      description: 'Quick tips and safety at a glance',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_safetyScreenStatusBarStyle);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_defaultStyle);
    super.dispose();
  }

  void _navigateToSafetyScreen(BuildContext context, int index) {
    final routes = [
      () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SafetyPreferencesScreen(),
            ),
          ),
      () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmergencyAssistanceScreen(),
            ),
          ),
      () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TrustedContactsScreen(),
            ),
          ),
      () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DeviceLockScreen(),
            ),
          ),
      () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LocationAlertsScreen(),
            ),
          ),
      () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SafetyOverviewScreen(),
            ),
          ),
    ];
    routes[index]();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        systemOverlayStyle: _safetyScreenStatusBarStyle,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: AppColors.textPrimary,
              ),
              const Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 28, color: AppColors.primary),
                    SizedBox(width: 16),
                    Icon(Icons.medical_services_outlined,
                        size: 28, color: AppColors.primary),
                    SizedBox(width: 16),
                    Icon(Icons.shield_outlined, size: 36, color: AppColors.primary),
                    SizedBox(width: 16),
                    Icon(Icons.medical_information_outlined,
                        size: 28, color: AppColors.primary),
                    SizedBox(width: 16),
                    Icon(Icons.monitor_heart_outlined,
                        size: 28, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _safetyItems[index];
                    return _SafetyItemCard(
                      icon: item.icon,
                      title: item.title,
                      description: item.description,
                      onTap: () => _navigateToSafetyScreen(context, index),
                    );
                  },
                  childCount: _safetyItems.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safety Check-up',
                style: AppTypography.pageTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'To help keep doctors and patients safe, review your current safety features.',
                style: AppTypography.bodySecondary.copyWith(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SafetyItemCard extends StatelessWidget {
  const _SafetyItemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
