import 'dart:convert';

import 'package:medigo_mobile/models/family_member.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists family members on the device, scoped to the signed-in account so
/// people sharing a phone never see each other's family.
class FamilyMembersService {
  static String _key(String userId) => 'family_members_$userId';

  static Future<List<FamilyMember>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(String userId, List<FamilyMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(userId),
      jsonEncode(members.map((m) => m.toJson()).toList()),
    );
  }
}
