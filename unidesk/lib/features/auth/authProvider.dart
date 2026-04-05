import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/mockApi.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  String? get userId => _userId;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isValidToken => _token != null && _token!.isNotEmpty;
  bool get isLoggedIn => isValidToken;

  AuthProvider() {
    loadToken();
  }

  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userId = prefs.getString('userId');
      final storedUser = prefs.getString('user');
      if (storedUser != null) {
        _user = jsonDecode(storedUser) as Map<String, dynamic>;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  Future<bool> login(String userId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await MockApi.login(userId, password);
      final success = result['success'] == true;

      if (success) {
        final token = (result['token'] ?? '') as String;
        if (token.isEmpty) {
          _errorMessage = 'Login succeeded but no token returned.';
        } else {
          _token = token;
          _userId = result['user']?['id']?.toString() ?? userId;
          _user = Map<String, dynamic>.from(result['user'] ?? {});

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          if (_userId != null) await prefs.setString('userId', _userId!);
          await prefs.setString('user', jsonEncode(_user ?? {}));

          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        _errorMessage = (result['message'] ?? 'Login failed').toString();
      }
    } catch (e) {
      _errorMessage = 'Unable to login. Please try again.';
    }

    _token = null;
    _userId = null;
    _user = null;
    _isLoading = false;
    notifyListeners();
    return false;
  }
  // check is admin 
  bool get isAdmin => _user?['role']?.toString().toLowerCase() == 'admin';
  // check is instructor
  bool get isInstructor => _user?['role']?.toString().toLowerCase() == 'instructor';

  
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _user = null;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('user');
    notifyListeners();
  }
}
