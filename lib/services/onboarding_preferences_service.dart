import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPreferencesService {
  static const _onboardingCompleteKey = 'patient_onboarding_complete';
  static const _tutorialDismissedKey = 'patient_tutorial_dismissed';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, value);
  }

  static Future<bool> isTutorialDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialDismissedKey) ?? false;
  }

  static Future<void> setTutorialDismissed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialDismissedKey, value);
  }
}
