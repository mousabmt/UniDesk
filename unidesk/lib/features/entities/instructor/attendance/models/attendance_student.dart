class AttendanceStudent {
  const AttendanceStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.absences,
    required this.status,
    required this.isPresent,
    this.userId = '',
  });

  final String id;
  final String name;
  final String email;
  final int absences;
  final String status;
  final bool isPresent;
  final String userId;

  factory AttendanceStudent.fromMap(Map<String, dynamic> map) {
    final attendanceStatus = map['attendance_status']?.toString() ?? '';
    return AttendanceStudent(
      id: map['id']?.toString() ??
          map['student_id']?.toString() ??
          map['user_id']?.toString() ??
          '',
      name: map['name']?.toString() ?? 'Unknown Student',
      email: map['email']?.toString() ?? 'No email available',
      absences: (map['absences'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'unknown',
      isPresent: map['isPresent'] as bool? ?? attendanceStatus.isNotEmpty,
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
    );
  }

  bool get isAtRisk => absences >= 3;
}
