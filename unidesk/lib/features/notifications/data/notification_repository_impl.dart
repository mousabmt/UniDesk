import 'package:unidesk/features/notifications/data/notification_history_data_source.dart';
import 'package:unidesk/features/notifications/domain/models/notification_item.dart';
import 'package:unidesk/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._dataSource);

  final NotificationHistoryDataSource _dataSource;

  @override
  Future<List<NotificationItem>> fetchHistory({int page = 1}) {
    return _dataSource.fetchHistory(page: page);
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return _dataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }

  @override
  Future<int> getUnreadCount() {
    return _dataSource.getUnreadCount();
  }
}
