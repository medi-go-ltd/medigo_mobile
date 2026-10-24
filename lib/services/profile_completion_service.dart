import 'dart:convert';

import 'package:medigo_mobile/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks deferred patient profile details and the finish-profile prompt cadence.
class ProfileCompletionService {
  static const _keyDismissedUntil = 'profile_prompt_dismissed_until';
  static const _keyJustSignedUp = 'profile_prompt_just_signed_up';
  static const _keyMedicalHistorySaved = 'profile_medical_history_saved';
  static const _keyDateOfBirth = 'profile_date_of_birth';
  static const _keyDeferredProfile = 'profile_deferred_details';
  static const Duration dismissCooldown = Duration(days: 3);

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<bool> hasSavedDateOfBirth() async {
    final prefs = await _prefs;
    final value = prefs.getString(_keyDateOfBirth);
    return value != null && value.trim().isNotEmpty;
  }

  static Future<String?> getDateOfBirth() async {
    final prefs = await _prefs;
    return prefs.getString(_keyDateOfBirth);
  }

  static Future<void> saveDateOfBirth(String isoDate) async {
    final prefs = await _prefs;
    await prefs.setString(_keyDateOfBirth, isoDate);
  }

  static Future<bool> isMedicalHistorySaved() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyMedicalHistorySaved) ?? false;
  }

  static Future<void> markMedicalHistorySaved() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyMedicalHistorySaved, true);
  }

  static Future<void> saveDeferredProfile(Map<String, dynamic> details) async {
    final prefs = await _prefs;
    await prefs.setString(_keyDeferredProfile, jsonEncode(details));
  }

  static Future<Map<String, dynamic>?> getDeferredProfile() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyDeferredProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isProfileIncomplete(User? user) async {
    if (user == null) return false;
    final phoneMissing =
        user.phoneNumber == null || user.phoneNumber!.trim().isEmpty;
    final genderMissing = user.gender == null || user.gender!.trim().isEmpty;
    final dobMissing = !(await hasSavedDateOfBirth());
    return phoneMissing || genderMissing || dobMissing;
  }

  static Future<void> markJustSignedUp() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyJustSignedUp, true);
  }

  static Future<bool> consumeJustSignedUpFlag() async {
    final prefs = await _prefs;
    final value = prefs.getBool(_keyJustSignedUp) ?? false;
    if (value) {
      await prefs.setBool(_keyJustSignedUp, false);
    }
    return value;
  }

  static Future<void> dismissPrompt() async {
    final prefs = await _prefs;
    final until = DateTime.now().add(dismissCooldown).toIso8601String();
    await prefs.setString(_keyDismissedUntil, until);
  }

  static Future<bool> shouldShowPrompt(User? user) async {
    if (user == null) return false;
    if (!(await isProfileIncomplete(user))) return false;

    final justSignedUp = await consumeJustSignedUpFlag();
    if (justSignedUp) return false;

    final prefs = await _prefs;
    final dismissedUntil = prefs.getString(_keyDismissedUntil);
    if (dismissedUntil != null) {
      final until = DateTime.tryParse(dismissedUntil);
      if (until != null && DateTime.now().isBefore(until)) {
        return false;
      }
    }
    return true;
  }

  static Future<void> clearForTests() async {
    final prefs = await _prefs;
    await prefs.remove(_keyDismissedUntil);
    await prefs.remove(_keyJustSignedUp);
    await prefs.remove(_keyMedicalHistorySaved);
    await prefs.remove(_keyDateOfBirth);
    await prefs.remove(_keyDeferredProfile);
  }
}
