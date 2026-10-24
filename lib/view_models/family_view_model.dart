import 'package:flutter/material.dart';
import 'package:medigo_mobile/models/family_member.dart';
import 'package:medigo_mobile/services/family_members_service.dart';
import 'package:medigo_mobile/view_models/auth_view_model.dart';

class FamilyViewModel extends ChangeNotifier {
  /// When [auth] is given, the family is cleared on logout and reloaded when a
  /// different account signs in.
  FamilyViewModel({AuthViewModel? auth}) : _auth = auth {
    _auth?.addListener(_onAuthChanged);
  }

  final AuthViewModel? _auth;
  String? _userId;
  Future<void>? _loading;
  List<FamilyMember> _members = [];
  bool _isLoading = false;

  List<FamilyMember> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;

  void _onAuthChanged() {
    final userId = _auth?.user?.id;
    if (userId == _userId) return;
    if (userId == null) {
      clear();
    } else {
      loadFor(userId);
    }
  }

  /// Loads the family for [userId]; no-op if it is already loaded.
  Future<void> loadFor(String userId) {
    if (_userId == userId) return _loading ?? Future.value();
    _userId = userId;
    _members = [];
    _isLoading = true;
    return _loading = _load(userId);
  }

  Future<void> _load(String userId) async {
    final loaded = await FamilyMembersService.load(userId);
    if (_userId != userId) return;
    _members = loaded;
    _isLoading = false;
    notifyListeners();
  }

  FamilyMember? byId(String id) {
    for (final member in _members) {
      if (member.id == id) return member;
    }
    return null;
  }

  Future<void> add(FamilyMember member) async {
    await _loading;
    _members = [..._members, member];
    notifyListeners();
    await _persist();
  }

  Future<void> update(FamilyMember member) async {
    await _loading;
    _members = [for (final m in _members) m.id == member.id ? member : m];
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    await _loading;
    _members = _members.where((m) => m.id != id).toList();
    notifyListeners();
    await _persist();
  }

  void clear() {
    _userId = null;
    _loading = null;
    _members = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    await FamilyMembersService.save(userId, _members);
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }
}
