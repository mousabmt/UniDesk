import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';
    /// background message handler (called outside main context)
 @pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalNotificationService.initialize();
  await LocalNotificationService.showNotification(
    title: message.notification?.title ?? 'Notification',
    body: message.notification?.body ?? '',
    payload: message.data,
  );
}
class FirebaseNotificationService {


  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Request user permission for notifications
  static Future<NotificationSettings> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings;
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Trigger local notification
    LocalNotificationService.showNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: message.data,
    );
  }

  /// Handle when user taps on notification from app opened state
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    print('Data: ${message.data}');
    // Navigation logic will be handled by UI layer using RouteObserver or similar
    // Service only provides the data, no direct navigation
  }

  /// Handle token refresh
  static void _handleTokenRefresh(String token) {
    print('FCM Token refreshed: $token');
    // Save token to backend or database if needed
  }



  /// Initialize Firebase Cloud Messaging
  static Future<void> initialize() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
      // Request permission
      final settings = await requestPermission();
      print('Notification permission: ${settings.authorizationStatus}');

      // Get initial token
      final token = await getFCMToken();
      print('Initial FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when user taps on notification while app is in foreground
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);
      //handles tap when app was fully terminated
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
      print('Firebase Notification Service initialized successfully');
    } catch (e) {
      print('Error initializing Firebase Notification Service: $e');
    }
  }
}
