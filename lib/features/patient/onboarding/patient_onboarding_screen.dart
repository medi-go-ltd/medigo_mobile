import 'package:flutter/material.dart';
import 'package:medigo_mobile/routes/app_routes.dart';
import 'package:medigo_mobile/services/onboarding_preferences_service.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/widgets/app_header.dart';

class PatientOnboardingScreen extends StatefulWidget {
  const PatientOnboardingScreen({super.key});

  @override
  State<PatientOnboardingScreen> createState() =>
      _PatientOnboardingScreenState();
}

class _PatientOnboardingScreenState extends State<PatientOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _termsAccepted = false;
  bool _communityAccepted = false;
  bool _dvDeclarationAccepted = false;
  bool _legalAccepted = false;
  bool _dontShowTutorial = false;

  static const _tutorialPages = [
    (
      icon: Icons.map_outlined,
      title: 'Find Doctors Nearby',
      body:
          'View available doctors on the map and book a home visit in minutes.',
    ),
    (
      icon: Icons.medical_services_outlined,
      title: 'Request Medical Care',
      body:
          'Select a doctor or use Find Nearest Available Doctor for urgent care.',
    ),
    (
      icon: Icons.shield_outlined,
      title: 'Stay Safe',
      body:
          'Add trusted contacts to share visit updates and access safety features.',
    ),
  ];

  bool get _allAccepted =>
      _termsAccepted &&
      _communityAccepted &&
      _dvDeclarationAccepted &&
      _legalAccepted;

  Future<void> _complete() async {
    await OnboardingPreferencesService.setOnboardingComplete(true);
    if (_dontShowTutorial) {
      await OnboardingPreferencesService.setTutorialDismissed(true);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildLegalPage(),
                  _buildTutorialPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Welcome to MediGo', style: AppTypography.pageTitle),
          const SizedBox(height: 8),
          const Text(
            'Please review and accept the following before using the app.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 24),
          _buildCheckbox(
            'Terms & Conditions',
            _termsAccepted,
            (v) => setState(() => _termsAccepted = v ?? false),
          ),
          _buildCheckbox(
            'Community Standards',
            _communityAccepted,
            (v) => setState(() => _communityAccepted = v ?? false),
          ),
          _buildCheckbox(
            'Domestic Violence Declaration',
            _dvDeclarationAccepted,
            (v) => setState(() => _dvDeclarationAccepted = v ?? false),
          ),
          _buildCheckbox(
            'Legal / Policy Documents',
            _legalAccepted,
            (v) => setState(() => _legalAccepted = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialPage() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: _tutorialPages.length,
            itemBuilder: (context, index) {
              final page = _tutorialPages[index];
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.highlight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(page.icon, size: 64, color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      style: AppTypography.pageTitle.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.body,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        CheckboxListTile(
          title: const Text("Don't show again"),
          value: _dontShowTutorial,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _dontShowTutorial = v ?? false),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label, style: AppTypography.body),
      value: value,
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentPage == 0
                  ? (_allAccepted
                      ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null)
                  : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(_currentPage == 0 ? 'Continue' : 'Start Using App'),
            ),
          ),
        ],
      ),
    );
  }
}
