import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  static const String _loginUrl =
      'http://127.0.0.1:8002/api/auth/login/student';

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
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          // API expects email; UI asks for student email/ID.
          'email': userId,
          'password': password,
        }),
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final accessToken = data['access_token'] as String?;
        if (accessToken == null || accessToken.isEmpty) {
          _errorMessage = 'Login succeeded but no access token returned.';
        } else {
          _token = accessToken;
          _userId = data['user']?['id']?.toString();
          _user = Map<String, dynamic>.from(data['user'] ?? {});

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          if (_userId != null) await prefs.setString('userId', _userId!);
          await prefs.setString('user', jsonEncode(_user ?? {}));

          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        _errorMessage = (data['message'] ?? 'Login failed').toString();
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
