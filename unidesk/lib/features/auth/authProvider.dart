import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_auth.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  bool _isLoading = false;

  String? get token => _token;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isValidToken => _token != null && MockAuth.isValidToken(_token);

  AuthProvider() {
    loadToken();
  }

  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userId = prefs.getString('userId');
      notifyListeners();
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  Future<void> login(String userId, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _token = MockAuth.token;
    _userId = userId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userId', _userId!);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    notifyListeners();
  }
}
