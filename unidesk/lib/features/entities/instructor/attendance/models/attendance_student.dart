class AttendanceStudent {
  const AttendanceStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.absences,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final int absences;
  final String status;

  factory AttendanceStudent.fromMap(Map<String, dynamic> map) {
    return AttendanceStudent(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Student',
      email: map['email']?.toString() ?? 'No email available',
      absences: (map['absences'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'unknown',
    );
  }

  bool get isAtRisk => absences >= 3;
}
