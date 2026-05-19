import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/student_api.dart';

class NotificationTokenRepository {
  NotificationTokenRepository({FirebaseMessaging? messaging})
    : _messaging = messaging;

  static const String _lastRegisteredTokenKey = 'last_registered_device_token';

  final FirebaseMessaging? _messaging;

  FirebaseMessaging get _resolvedMessaging =>
      _messaging ?? FirebaseMessaging.instance;

  Future<void> registerCurrentDeviceToken({String? authToken}) async {
    final token = await _resolvedMessaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await registerDeviceToken(token, authToken: authToken);
  }

  Future<void> registerDeviceToken(
    String deviceToken, {
    String? authToken,
  }) async {
    authToken ??= await StudentApi.readToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        'NotificationTokenRepository: no auth token available, skipping device token registration.',
      );
      return;
    }

    final response = await StudentApi.registerDeviceToken(
      deviceToken: deviceToken,
      deviceType: _resolveDeviceType(),
      token: authToken,
    );

    if (response['success'] != true) {
      throw NotificationTokenRepositoryException(
        response['message']?.toString() ?? 'Failed to register device token',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRegisteredTokenKey, deviceToken);
  }

  Future<void> removeCurrentDeviceToken({String? authToken}) async {
    final currentToken = await _resolvedMessaging.getToken();
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_lastRegisteredTokenKey);
    final tokenToRemove = currentToken?.isNotEmpty == true
        ? currentToken!
        : storedToken;

    if (tokenToRemove == null || tokenToRemove.isEmpty) {
      return;
    }

    await removeDeviceToken(tokenToRemove, authToken: authToken);
  }

  Future<void> removeDeviceToken(
    String deviceToken, {
    String? authToken,
  }) async {
    authToken ??= await StudentApi.readToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint(
        'NotificationTokenRepository: no auth token available, skipping device token removal.',
      );
      return;
    }

    final response = await StudentApi.removeDeviceToken(
      deviceToken: deviceToken,
      token: authToken,
    );

    if (response['success'] != true) {
      throw NotificationTokenRepositoryException(
        response['message']?.toString() ?? 'Failed to remove device token',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRegisteredTokenKey);
  }

  String _resolveDeviceType() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}

class NotificationTokenRepositoryException implements Exception {
  const NotificationTokenRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
