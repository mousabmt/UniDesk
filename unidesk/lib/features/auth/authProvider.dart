import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/notifications/data/notification_token_repository.dart';

class AuthProvider extends ChangeNotifier {
  final NotificationTokenRepository _notificationTokenRepository;
  final Future<void> Function(String token) _logoutRequest;

  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  SharedPreferences? _prefs;

  String? _token;
  String? _userId;
  Map<String, dynamic>? _user;
  String? _role;
  bool _isLoading = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  String? get token => _token;
  String? get userId => _userId;
  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;
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
    Future<void> Function(String token)? logoutRequest,
  }) : _notificationTokenRepository =
           notificationTokenRepository ?? NotificationTokenRepository(),
       _logoutRequest =
           logoutRequest ?? ((token) => StudentApi.logout(token: token)) {
    loadToken();
  }

  // ── Secure-storage abstraction (web ↔ native) ──────────────────────────────

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Reads the token from the appropriate storage for the current platform.
  Future<String?> _readToken() async {
    if (kIsWeb) {
      final prefs = await _preferences();
      return prefs.getString(_tokenKey);
    }
    return _secureStorage.read(key: _tokenKey);
  }

  /// Writes the token to the appropriate storage for the current platform.
  Future<void> _writeToken(String value) async {
    if (kIsWeb) {
      final prefs = await _preferences();
      await prefs.setString(_tokenKey, value);
    } else {
      await _secureStorage.write(key: _tokenKey, value: value);
    }
  }

  /// Deletes the token from the appropriate storage for the current platform.
  Future<void> _deleteToken() async {
    if (kIsWeb) {
      final prefs = await _preferences();
      await prefs.remove(_tokenKey);
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
      final prefs = await _preferences();

      // Must init _prefs before calling _readToken()
      _token = await _readToken();

      _userId = prefs.getString('userId');
      _role = prefs.getString('role');

      final storedUser = prefs.getString('user');
      if (storedUser != null) {
        try {
          final decoded = jsonDecode(storedUser);
          if (decoded is Map<String, dynamic>) {
            _user = decoded;
          }
        } catch (e) {
          debugPrint('Corrupt user JSON in prefs, clearing: $e');
          await prefs.remove('user');
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

        final prefs = await _preferences();
        if (_userId != null) await prefs.setString('userId', _userId!);
        await prefs.setString('user', jsonEncode(_user ?? {}));
        if (_role != null) await prefs.setString('role', _role!);

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
    if (_isLoggingOut) {
      return;
    }

    final tokenToRevoke = _token;
    _isLoggingOut = true;
    _isLoading = false;
    _token = null;
    _userId = null;
    _user = null;
    _role = null;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteToken();
    } catch (e) {
      debugPrint('Error deleting local auth token during logout: $e');
    }

    try {
      final prefs = await _preferences();
      await prefs.remove('userId');
      await prefs.remove('user');
      await prefs.remove('role');
    } catch (e) {
      debugPrint('Error clearing local auth metadata during logout: $e');
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }

    if (tokenToRevoke == null || tokenToRevoke.isEmpty) {
      return;
    }

    unawaited(_finishRemoteLogout(tokenToRevoke));
  }

  Future<void> _finishRemoteLogout(String tokenToRevoke) async {
    try {
      await _notificationTokenRepository.removeCurrentDeviceToken(
        authToken: tokenToRevoke,
      );
    } catch (e) {
      debugPrint('Error removing device token during logout: $e');
    }

    try {
      await _logoutRequest(tokenToRevoke);
    } catch (e) {
      debugPrint('Error calling backend logout: $e');
    }
  }
}
