import 'dart:convert';

class AttendanceSession {
  const AttendanceSession({
    required this.sessionId,
    required this.token,
    required this.courseId,
    required this.lectureId,
    required this.expiresAt,
    required this.isActive,
  });

  final String sessionId;
  final String token;
  final String courseId;
  final String lectureId;
  final DateTime expiresAt;
  final bool isActive;

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      sessionId: map['session_id']?.toString() ??
          map['sessionId']?.toString() ??
          map['id']?.toString() ??
          '',
      token: map['token']?.toString() ?? '',
      courseId:
          map['courseId']?.toString() ?? map['course_id']?.toString() ?? '',
      lectureId:
          map['lectureId']?.toString() ?? map['lecture_id']?.toString() ?? '',
      expiresAt: DateTime.tryParse(
            map['expiresAt']?.toString() ?? map['expires_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      isActive: map['isActive'] as bool? ?? map['is_active'] as bool? ?? true,
    );
  }

  String get qrPayload => jsonEncode({
        'token': token,
        'courseId': courseId,
      });
}
