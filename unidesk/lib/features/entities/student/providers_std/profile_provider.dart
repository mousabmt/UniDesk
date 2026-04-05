import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/mockApi.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded() async {
    if (_profile != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Prefer the user object saved at login time.
      final prefs = await SharedPreferences.getInstance();
      final storedUser = prefs.getString('user');

      if (storedUser != null) {
        _profile = jsonDecode(storedUser) as Map<String, dynamic>;
      } else {
        _profile = await MockApi.getProfile();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
    Future<void> refresh() async {
  _profile = null; // clear cache
  await loadIfNeeded();
}
}
