import 'package:unidesk/core/services/mockApi.dart';
import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_session.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_student.dart';

class AttendanceRepository {
  final Map<String, String> _latestSessionIdsByCourseId = <String, String>{};
  final Map<String, String> _sessionIdsByToken = <String, String>{};

  Future<List<AttendanceCourse>> getInstructorCourses(String instructorId) async {
    final token = await StudentApi.readToken();
    if (token == null || token.isEmpty) {
      return _getInstructorCoursesFromMock(instructorId);
    }

    try {
      final courses = await StudentApi.getInstructorCourses(token: token);
      final normalized = await Future.wait(courses.map((course) async {
        final sectionId =
            course['sectionId']?.toString() ?? course['lectureId']?.toString() ?? '';
        if (sectionId.isEmpty) {
          return course;
        }

        try {
          final students = await StudentApi.getSectionStudents(
            sectionId: sectionId,
            token: token,
          );
          return {
            ...course,
            'studentsEnrolled': students.length,
          };
        } catch (_) {
          return course;
        }
      }));

      return normalized.map(AttendanceCourse.fromMap).toList();
    } catch (error) {
      throw AttendanceRepositoryException(error.toString());
    }
  }

  Future<List<AttendanceStudent>> getCourseStudents({
    required String courseId,
    required String lectureId,
  }) async {
    final token = await StudentApi.readToken();
    if (token == null || token.isEmpty) {
      return _getCourseStudentsFromMock(courseId: courseId, lectureId: lectureId);
    }

    try {
      final students = await StudentApi.getSectionStudents(
        sectionId: lectureId,
        token: token,
      );
      final sessionId = _latestSessionIdsByCourseId[courseId];
      if (sessionId == null || sessionId.isEmpty) {
        return students.map(AttendanceStudent.fromMap).toList();
      }

      final sessionResponse = await StudentApi.getAttendanceSession(
        sessionId: sessionId,
        token: token,
      );
      final data = sessionResponse['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(sessionResponse['data'] as Map<String, dynamic>)
          : const <String, dynamic>{};
      final attendance = List<Map<String, dynamic>>.from(data['attendance'] ?? const []);

      final attendanceByUserId = <String, Map<String, dynamic>>{
        for (final record in attendance)
          record['user_id']?.toString() ?? '': record,
      };

      final merged = students.map((student) {
        final userId = student['userId']?.toString() ?? student['user_id']?.toString() ?? '';
        final record = attendanceByUserId[userId];
        final attendanceStatus = record?['status']?.toString() ?? '';
        return {
          ...student,
          'isPresent': _isPresentAttendanceStatus(attendanceStatus),
          'attendance_status': attendanceStatus,
          'status': attendanceStatus.isNotEmpty ? attendanceStatus : student['status'],
        };
      }).toList();

      return merged.map(AttendanceStudent.fromMap).toList();
    } catch (error) {
      throw AttendanceRepositoryException(error.toString());
    }
  }

  Future<AttendanceSession> startAttendanceSession({
    required String courseId,
    required String lectureId,
  }) async {
    final token = await StudentApi.readToken();
    if (token == null || token.isEmpty) {
      return _startAttendanceSessionFromMock(courseId: courseId, lectureId: lectureId);
    }

    try {
      final response = await StudentApi.startAttendanceSession(
        courseId: courseId,
        lectureId: lectureId,
        token: token,
      );
      if (response['success'] != true) {
        throw AttendanceRepositoryException(
          response['message']?.toString() ?? 'Failed to start attendance session',
        );
      }

      final session = AttendanceSession.fromMap(
        Map<String, dynamic>.from(response['data'] ?? const {}),
      );
      _latestSessionIdsByCourseId[courseId] = session.sessionId;
      _sessionIdsByToken[session.token] = session.sessionId;
      return session;
    } catch (error) {
      throw AttendanceRepositoryException(error.toString());
    }
  }

  Future<void> closeAttendanceSession(String token) async {
    final authToken = await StudentApi.readToken();
    if (authToken == null || authToken.isEmpty) {
      await _closeAttendanceSessionFromMock(token);
      return;
    }

    try {
      final sessionId = _sessionIdsByToken[token];
      if (sessionId == null || sessionId.isEmpty) {
        throw const AttendanceRepositoryException('Attendance session id is missing');
      }

      final response = await StudentApi.closeAttendanceSession(
        sessionId: sessionId,
        sessionToken: token,
        token: authToken,
      );
      if (response['success'] != true) {
        throw AttendanceRepositoryException(
          response['message']?.toString() ?? 'Failed to close attendance session',
        );
      }
    } catch (error) {
      throw AttendanceRepositoryException(error.toString());
    }
  }

  Future<void> registerAttendance({
    required String token,
    required String courseId,
    required String studentId,
  }) async {
    final authToken = await StudentApi.readToken();
    if (authToken == null || authToken.isEmpty) {
      await _registerAttendanceWithMock(
        token: token,
        courseId: courseId,
        studentId: studentId,
      );
      return;
    }

    final response = await StudentApi.registerAttendance(
      token: token,
      courseId: courseId,
    );
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to register attendance',
      );
    }
  }

  Future<List<AttendanceCourse>> _getInstructorCoursesFromMock(
    String instructorId,
  ) async {
    final response = await MockApi.getInstructorCourses(instructorId);
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to fetch courses',
      );
    }

    final data = List<Map<String, dynamic>>.from(response['data'] ?? const []);
    return data.map(AttendanceCourse.fromMap).toList();
  }

  Future<List<AttendanceStudent>> _getCourseStudentsFromMock({
    required String courseId,
    required String lectureId,
  }) async {
    final response = await MockApi.getCourseStudents(courseId, lectureId);
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to fetch students',
      );
    }

    final data = List<Map<String, dynamic>>.from(response['data'] ?? const []).map((student) {
      return {
        ...student,
        if (_sessionIdsByToken.isEmpty) 'isPresent': false,
      };
    }).toList();
    return data.map(AttendanceStudent.fromMap).toList();
  }

  Future<AttendanceSession> _startAttendanceSessionFromMock({
    required String courseId,
    required String lectureId,
  }) async {
    final response = await MockApi.startAttendanceSession(
      courseId: courseId,
      lectureId: lectureId,
    );
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to start attendance session',
      );
    }

    final session = AttendanceSession.fromMap(
      Map<String, dynamic>.from(response['data'] ?? const {}),
    );
    _sessionIdsByToken[session.token] = session.sessionId;
    return session;
  }

  Future<void> _closeAttendanceSessionFromMock(String token) async {
    final response = await MockApi.closeAttendanceSession(token);
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to close attendance session',
      );
    }
  }

  Future<void> _registerAttendanceWithMock({
    required String token,
    required String courseId,
    required String studentId,
  }) async {
    final response = await MockApi.registerAttendance(
      token: token,
      courseId: courseId,
      studentId: studentId,
    );
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to register attendance',
      );
    }
  }

  bool _isPresentAttendanceStatus(String rawStatus) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'present':
      case 'late':
        return true;
      default:
        return false;
    }
  }
}

class AttendanceRepositoryException implements Exception {
  const AttendanceRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
