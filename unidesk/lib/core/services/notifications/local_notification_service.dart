import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications for Android and iOS
  static Future<void> initialize() async {
    try {
      // Android initialization
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iOSInitSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize with both Android and iOS settings
      final InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iOSInitSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
      );

      // Create Android notification channel
      await _createAndroidNotificationChannel();

      print('Local Notification Service initialized successfully');
    } catch (e) {
      print('Error initializing Local Notification Service: $e');
    }
  }

  /// Create Android notification channel
  static Future<void> _createAndroidNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'unidesk_notifications', // Channel ID
        'UniDesk Notifications', // Channel name
        description: 'Channel for UniDesk notifications',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      print('Android notification channel created');
    } catch (e) {
      print('Error creating Android notification channel: $e');
    }
  }

  /// Show a local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    int id = 0,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'unidesk_notifications',
        'UniDesk Notifications',
        channelDescription: 'Channel for UniDesk notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'unidesk_notifications',
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final payloadString =
          payload != null ? jsonEncode(payload) : '';

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payloadString,
      );

      print('Notification displayed: $title - $body');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  /// Handle notification tap
  static Future<void> _onSelectNotification(
    NotificationResponse notificationResponse,
  ) async {
    print('Notification tapped: ${notificationResponse.id}');
    print('Payload: ${notificationResponse.payload}');
    // Navigation logic handled by UI layer
    // The payload can be decoded and used for routing decisions
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('Notification $id cancelled');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}
