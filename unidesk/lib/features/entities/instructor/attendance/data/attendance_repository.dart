import 'package:unidesk/core/services/mockApi.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_session.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_student.dart';

class AttendanceRepository {
  Future<List<AttendanceCourse>> getInstructorCourses(String instructorId) async {
    final response = await MockApi.getInstructorCourses(instructorId);
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to fetch courses',
      );
    }

    final data = List<Map<String, dynamic>>.from(response['data'] ?? const []);
    return data.map(AttendanceCourse.fromMap).toList();
  }

  Future<List<AttendanceStudent>> getCourseStudents({
    required String courseId,
    required String lectureId,
  }) async {
    final response = await MockApi.getCourseStudents(courseId, lectureId);
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to fetch students',
      );
    }

    final data = List<Map<String, dynamic>>.from(response['data'] ?? const []);
    return data.map(AttendanceStudent.fromMap).toList();
  }

  Future<AttendanceSession> startAttendanceSession({
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

    return AttendanceSession.fromMap(
      Map<String, dynamic>.from(response['data'] ?? const {}),
    );
  }

  Future<void> closeAttendanceSession(String token) async {
    final response = await MockApi.closeAttendanceSession(token);
    if (response['success'] != true) {
      throw AttendanceRepositoryException(
        response['message']?.toString() ?? 'Failed to close attendance session',
      );
    }
  }
}

class AttendanceRepositoryException implements Exception {
  const AttendanceRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
