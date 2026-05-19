import 'package:flutter/material.dart';
import 'package:unidesk/features/notifications/domain/models/notification_item.dart';
import 'package:unidesk/features/notifications/domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._repository) {
    Future.microtask(_initialize);
  }

  final NotificationRepository _repository;

  List<NotificationItem> _notifications = const [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  bool _hasLoadedOnce = false;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _notifications.isNotEmpty;

  Future<void> _initialize() async {
    await refreshUnreadCount();
  }

  Future<void> loadHistory({bool force = false}) async {
    if (_isLoading) {
      return;
    }
    if (_hasLoadedOnce && !force) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final history = await _repository.fetchHistory();
      history.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );
      _notifications = List<NotificationItem>.unmodifiable(history);
      _hasLoadedOnce = true;
    } catch (error) {
      _notifications = const [];
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadHistory(force: true);
    await refreshUnreadCount();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final index = _notifications.indexWhere(
        (item) => item.id == notificationId,
      );
      if (index != -1) {
        _notifications = List<NotificationItem>.unmodifiable([
          ..._notifications.sublist(0, index),
          _notifications[index].copyWith(isRead: true),
          ..._notifications.sublist(index + 1),
        ]);
      }
      await refreshUnreadCount();
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications
          .map((item) => item.copyWith(isRead: true))
          .toList(growable: false);
      await refreshUnreadCount();
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }
}
