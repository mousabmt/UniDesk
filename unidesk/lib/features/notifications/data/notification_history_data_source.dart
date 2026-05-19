import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/notifications/domain/models/notification_item.dart';

abstract class NotificationHistoryDataSource {
  Future<List<NotificationItem>> fetchHistory({int page = 1});
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}

class ApiNotificationHistoryDataSource implements NotificationHistoryDataSource {
  const ApiNotificationHistoryDataSource();

  @override
  Future<List<NotificationItem>> fetchHistory({int page = 1}) async {
    final response = await StudentApi.getNotificationsHistory(page: page);
    final responseData = response['data'];
    if (responseData is! Map<String, dynamic>) {
      throw Exception('Unexpected notification history payload');
    }

    final items = responseData['data'];
    if (items is! List) {
      return const [];
    }

    return items.map<NotificationItem>((dynamic item) {
      return NotificationItem.fromMap(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    final response = await StudentApi.markNotificationRead(notificationId);
    if (response['success'] != true) {
      throw Exception(response['message']?.toString() ?? 'Failed to mark read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await StudentApi.markAllNotificationsRead();
    if (response['success'] != true) {
      throw Exception(response['message']?.toString() ?? 'Failed to mark all read');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    return await StudentApi.getUnreadNotificationCount();
  }
}
