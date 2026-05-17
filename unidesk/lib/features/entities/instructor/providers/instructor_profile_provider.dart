import 'package:flutter/material.dart';

class InstructorProfileProvider extends ChangeNotifier {
  InstructorProfileProvider({
    required Future<Map<String, dynamic>> Function() fetchProfile,
    Future<void> Function(Map<String, dynamic> profile)? saveProfile,
  }) : _fetchProfile = fetchProfile,
       _saveProfile = saveProfile;

  final Future<Map<String, dynamic>> Function() _fetchProfile;
  final Future<void> Function(Map<String, dynamic> profile)? _saveProfile;

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSaving = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> loadIfNeeded() async {
    if (_profile != null || _isLoading) return;
    await _load(isRefresh: false);
  }

  Future<void> refresh() async {
    await _load(isRefresh: true);
  }

  Future<void> savePersonalInfo(Map<String, dynamic> updates) async {
    final current = _profile;
    if (current == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    final updatedProfile = Map<String, dynamic>.from(current)..addAll(updates);

    try {
      await _saveProfile?.call(updatedProfile);
      _profile = updatedProfile;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _load({required bool isRefresh}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();

    try {
      _profile = await _fetchProfile();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
