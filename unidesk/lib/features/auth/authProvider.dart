import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/notifications/data/notification_token_repository.dart';

class AuthProvider extends ChangeNotifier {
  final NotificationTokenRepository _notificationTokenRepository;

  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  late final SharedPreferences _prefs;

  String? _token;
  String? _userId;
  Map<String, dynamic>? _user;
  String? _role;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  String? get userId => _userId;
  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isValidToken => _token != null && _token!.isNotEmpty;
  bool get isLoggedIn => isValidToken;
  String? get _resolvedRole =>
      (_role ?? _user?['role'])?.toString().toLowerCase();

  bool get isAdmin => _resolvedRole == 'admin';
  bool get isInstructor => _resolvedRole == 'instructor';
  bool get isStudent => _resolvedRole == 'student';

  AuthProvider({
    NotificationTokenRepository? notificationTokenRepository,
  }) : _notificationTokenRepository =
            notificationTokenRepository ?? NotificationTokenRepository() {
    loadToken();
  }

  // ── Secure-storage abstraction (web ↔ native) ──────────────────────────────

  /// Reads the token from the appropriate storage for the current platform.
  Future<String?> _readToken() async {
    if (kIsWeb) {
      return _prefs.getString(_tokenKey);
    }
    return _secureStorage.read(key: _tokenKey);
  }

  /// Writes the token to the appropriate storage for the current platform.
  Future<void> _writeToken(String value) async {
    if (kIsWeb) {
      await _prefs.setString(_tokenKey, value);
    } else {
      await _secureStorage.write(key: _tokenKey, value: value);
    }
  }

  /// Deletes the token from the appropriate storage for the current platform.
  Future<void> _deleteToken() async {
    if (kIsWeb) {
      await _prefs.remove(_tokenKey);
    } else {
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _syncDeviceToken() async {
    try {
      await _notificationTokenRepository.registerCurrentDeviceToken(
        authToken: _token,
      );
    } catch (e) {
      debugPrint('Error syncing device token: $e');
    }
  }

  Future<void> loadToken() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Must init _prefs before calling _readToken()
      _token = await _readToken();

      _userId = _prefs.getString('userId');
      _role = _prefs.getString('role');

      final storedUser = _prefs.getString('user');
      if (storedUser != null) {
        try {
          final decoded = jsonDecode(storedUser);
          if (decoded is Map<String, dynamic>) {
            _user = decoded;
          }
        } catch (e) {
          debugPrint('Corrupt user JSON in prefs, clearing: $e');
          await _prefs.remove('user');
        }
      }

      if (isValidToken) {
        await _syncDeviceToken();
      }
    } catch (e) {
      debugPrint('Error loading token: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String userId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await StudentApi.login(userId, password);
      final success = result['success'] == true;

      if (success) {
        final token = (result['token'] ?? '') as String;
        final responseUser = Map<String, dynamic>.from(result['user'] ?? {});
        _role = result['role']?.toString() ?? responseUser['role']?.toString();

        if (token.isEmpty) {
          _errorMessage = 'Login succeeded but no token returned.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _token = token;
        _userId = responseUser['id']?.toString() ?? userId;
        _user = responseUser;
        if (_role != null) _user!['role'] = _role;

        await _writeToken(_token!);

        if (_userId != null) await _prefs.setString('userId', _userId!);
        await _prefs.setString('user', jsonEncode(_user ?? {}));
        if (_role != null) await _prefs.setString('role', _role!);

        await _syncDeviceToken();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = (result['message'] ?? 'Login failed').toString();
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = 'Unable to login. Please try again.';
    }

    _token = null;
    _userId = null;
    _user = null;
    _role = null;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _notificationTokenRepository.removeCurrentDeviceToken(
        authToken: _token,
      );
    } catch (e) {
      debugPrint('Error removing device token during logout: $e');
    }

    try {
      await StudentApi.logout(token: _token);
    } catch (_) {}

    _token = null;
    _userId = null;
    _user = null;
    _role = null;
    _errorMessage = null;

    await _deleteToken();

    await _prefs.remove('userId');
    await _prefs.remove('user');
    await _prefs.remove('role');

    notifyListeners();
  }
}