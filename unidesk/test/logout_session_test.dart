import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/student/materials/data/student_materials_repository.dart';
import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';
import 'package:unidesk/features/entities/student/materials/models/student_material_course_option.dart';
import 'package:unidesk/features/entities/student/materials/providers/student_materials_provider.dart';
import 'package:unidesk/features/notifications/data/notification_token_repository.dart';
import 'package:unidesk/features/notifications/domain/models/notification_item.dart';
import 'package:unidesk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:unidesk/features/notifications/presentation/providers/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
              return 'session-token';
            case 'delete':
            case 'write':
              return null;
          }
          return null;
        });
    SharedPreferences.setMockInitialValues({
      'token': 'session-token',
      'userId': 'student@example.com',
      'role': 'student',
      'user': '{"id":"student@example.com","role":"student"}',
    });
  });

  test('logout clears auth state before remote logout finishes', () async {
    final remoteLogout = Completer<void>();
    var remoteLogoutStarted = false;
    final auth = AuthProvider(
      notificationTokenRepository: _FakeNotificationTokenRepository(),
      logoutRequest: (token) {
        remoteLogoutStarted = true;
        expect(token, 'session-token');
        return remoteLogout.future;
      },
    );
    await _waitFor(() => auth.isLoggedIn);

    expect(auth.isLoggedIn, isTrue);

    await auth.logout();
    await Future<void>.delayed(Duration.zero);

    expect(auth.isLoggedIn, isFalse);
    expect(auth.token, isNull);
    expect(auth.userId, isNull);
    expect(auth.user, isNull);
    expect(auth.role, isNull);
    expect(auth.isLoggingOut, isFalse);
    expect(remoteLogoutStarted, isTrue);
    expect(remoteLogout.isCompleted, isFalse);

    remoteLogout.complete();
  });

  test(
    'student materials provider clear removes loaded session data',
    () async {
      final provider = StudentMaterialsProvider(
        _FakeStudentMaterialsRepository(),
      );
      await provider.loadIfNeeded(
        courseOptions: const [
          StudentMaterialCourseOption(
            selectionValue: '120414',
            materialsCourseId: '120414',
            displayLabel: '120414 - Programming',
          ),
        ],
      );

      expect(provider.materials, isNotEmpty);
      expect(provider.selectedCourseSelectionValue, '120414');

      provider.clear();

      expect(provider.materials, isEmpty);
      expect(provider.selectedCourseSelectionValue, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    },
  );

  test(
    'notification provider clear removes unread count and history',
    () async {
      final provider = NotificationProvider(_FakeNotificationRepository());
      await provider.loadHistory(force: true);

      expect(provider.notifications, isNotEmpty);

      provider.clear();

      expect(provider.notifications, isEmpty);
      expect(provider.unreadCount, 0);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    },
  );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var index = 0; index < 20; index += 1) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _FakeNotificationTokenRepository extends NotificationTokenRepository {
  @override
  Future<void> registerCurrentDeviceToken({String? authToken}) async {}

  @override
  Future<void> removeCurrentDeviceToken({String? authToken}) async {}
}

class _FakeStudentMaterialsRepository implements StudentMaterialsRepository {
  @override
  Future<List<StudentCourseMaterial>> getMaterialsByCourse(String courseId) {
    return Future.value([
      StudentCourseMaterial.fromMap({
        'id': 1,
        'title': 'Lecture 1',
        'course_id': courseId,
        'file_url': 'https://example.com/lecture.pdf',
      }),
    ]);
  }
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<NotificationItem>> fetchHistory({int page = 1}) {
    return Future.value([
      NotificationItem(
        id: 1,
        userId: 7,
        title: 'Welcome',
        body: 'Hello',
        type: 'general',
        data: const {},
        isRead: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ]);
  }

  @override
  Future<int> getUnreadCount() async => 1;

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(int notificationId) async {}
}
