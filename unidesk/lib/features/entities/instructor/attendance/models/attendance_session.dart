import 'dart:convert';

class AttendanceSession {
  const AttendanceSession({
    required this.token,
    required this.courseId,
    required this.lectureId,
    required this.expiresAt,
    required this.isActive,
  });

  final String token;
  final String courseId;
  final String lectureId;
  final DateTime expiresAt;
  final bool isActive;

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      token: map['token']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      lectureId: map['lectureId']?.toString() ?? '',
      expiresAt: DateTime.tryParse(map['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  String get qrPayload => jsonEncode({
        'token': token,
        'courseId': courseId,
      });
}
