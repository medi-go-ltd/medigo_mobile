import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists safety check-up preferences (Uber-style + medical app patterns).
class SafetyPreferencesService {
  static const String _keyShareTripWithContacts = 'safety_share_trip_with_contacts';
  static const String _keyLocationAlertsEnabled = 'safety_location_alerts_enabled';
  static const String _keyDeviceLockEnabled = 'safety_device_lock_enabled';
  static const String _keyCheckInIntervalMinutes = 'safety_check_in_interval_minutes';
  static const String _keyTrustedContacts = 'safety_trusted_contacts';
  static const String _keyEmergencyNumber = 'safety_emergency_number';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<bool> getShareTripWithContacts() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyShareTripWithContacts) ?? true;
  }

  static Future<bool> setShareTripWithContacts(bool value) async {
    final prefs = await _prefs;
    return prefs.setBool(_keyShareTripWithContacts, value);
  }

  static Future<bool> getLocationAlertsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyLocationAlertsEnabled) ?? true;
  }

  static Future<bool> setLocationAlertsEnabled(bool value) async {
    final prefs = await _prefs;
    return prefs.setBool(_keyLocationAlertsEnabled, value);
  }

  static Future<bool> getDeviceLockEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDeviceLockEnabled) ?? false;
  }

  static Future<bool> setDeviceLockEnabled(bool value) async {
    final prefs = await _prefs;
    return prefs.setBool(_keyDeviceLockEnabled, value);
  }

  static Future<int> getCheckInIntervalMinutes() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyCheckInIntervalMinutes) ?? 15;
  }

  static Future<bool> setCheckInIntervalMinutes(int minutes) async {
    final prefs = await _prefs;
    return prefs.setInt(_keyCheckInIntervalMinutes, minutes);
  }

  static Future<String?> getEmergencyNumber() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmergencyNumber);
  }

  static Future<bool> setEmergencyNumber(String? value) async {
    final prefs = await _prefs;
    if (value == null || value.isEmpty) {
      return prefs.remove(_keyEmergencyNumber);
    }
    return prefs.setString(_keyEmergencyNumber, value);
  }

  static Future<List<TrustedContact>> getTrustedContacts() async {
    final prefs = await _prefs;
    final json = prefs.getString(_keyTrustedContacts);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => TrustedContact.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> setTrustedContacts(List<TrustedContact> contacts) async {
    final prefs = await _prefs;
    final json = jsonEncode(contacts.map((e) => e.toJson()).toList());
    return prefs.setString(_keyTrustedContacts, json);
  }

  static Future<bool> addTrustedContact(TrustedContact contact) async {
    final list = await getTrustedContacts();
    if (list.any((c) => c.phone == contact.phone)) return true;
    list.add(contact);
    return setTrustedContacts(list);
  }

  static Future<bool> removeTrustedContact(String phone) async {
    final list = await getTrustedContacts();
    list.removeWhere((c) => c.phone == phone);
    return setTrustedContacts(list);
  }
}

class TrustedContact {
  const TrustedContact({
    required this.name,
    required this.phone,
    this.email,
  });

  final String name;
  final String phone;
  final String? email;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
      };

  static TrustedContact fromJson(Map<String, dynamic> json) => TrustedContact(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
      );
}
