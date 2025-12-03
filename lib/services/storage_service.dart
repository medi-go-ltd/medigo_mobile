import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medigo_mobile/models/user.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<bool> saveToken(String token) async {
    final prefs = await _prefs;
    return await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyToken);
  }

  static Future<bool> saveUser(User user) async {
    final prefs = await _prefs;
    final userJson = jsonEncode(user.toJson());
    return await prefs.setString(_keyUser, userJson);
  }

  static Future<User?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _prefs;
    return await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<bool> clearAuthData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyIsLoggedIn);
    return true;
  }

  static Future<bool> clearAll() async {
    final prefs = await _prefs;
    return await prefs.clear();
  }
}
