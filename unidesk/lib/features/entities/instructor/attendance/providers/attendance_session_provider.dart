import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_session.dart';

enum AttendanceSessionStatus { idle, loading, success, error }

class AttendanceSessionProvider extends ChangeNotifier {
  AttendanceSessionProvider(this._repository);

  final AttendanceRepository _repository;

  AttendanceSessionStatus _status = AttendanceSessionStatus.idle;
  String? _errorMessage;
  AttendanceSession? _currentSession;

  AttendanceSessionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AttendanceSession? get currentSession => _currentSession;
  bool get isLoading => _status == AttendanceSessionStatus.loading;
  bool get hasError => _status == AttendanceSessionStatus.error;
  bool get hasActiveSession => _currentSession != null;
  String? get qrData => _currentSession?.qrPayload;

  Future<void> startForCourse(AttendanceCourse course) async {
    _status = AttendanceSessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _repository.startAttendanceSession(
        courseId: course.id,
        lectureId: course.lectureId,
      );
      _status = AttendanceSessionStatus.success;
    } on AttendanceRepositoryException catch (error) {
      _currentSession = null;
      _errorMessage = error.message;
      _status = AttendanceSessionStatus.error;
    }

    notifyListeners();
  }

  Future<void> closeCurrentSession() async {
    final session = _currentSession;
    if (session == null) {
      return;
    }

    _status = AttendanceSessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.closeAttendanceSession(session.token);
      _currentSession = null;
      _status = AttendanceSessionStatus.success;
    } on AttendanceRepositoryException catch (error) {
      _errorMessage = error.message;
      _status = AttendanceSessionStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _currentSession = null;
    _errorMessage = null;
    _status = AttendanceSessionStatus.idle;
    notifyListeners();
  }
}
