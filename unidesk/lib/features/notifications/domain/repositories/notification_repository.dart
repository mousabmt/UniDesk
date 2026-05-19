import '../models/notification_item.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> fetchHistory({int page = 1});
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}
