import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/student_api.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded({String? token}) async {
    if (_profile != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final storedUser = prefs.getString('user');

      if (token != null && token.isNotEmpty) {
        _profile = await StudentApi.getProfile(token: token);
        await prefs.setString('user', jsonEncode(_profile));
      } else if (storedUser != null) {
        _profile = jsonDecode(storedUser) as Map<String, dynamic>;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _profile = null;
    await loadIfNeeded();
  }
}
