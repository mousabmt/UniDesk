class AttendanceStudent {
  AttendanceStudent({
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

  // Computed once on first access — avoids running a regex split inside
  // build() on every poll-driven list refresh.
  late final String initials = _computeInitials(name);

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1 || parts.last.isEmpty) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

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
      isPresent:
          map['isPresent'] as bool? ?? _isPresentStatus(attendanceStatus),
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
    );
  }

  static bool _isPresentStatus(String rawStatus) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'present':
      case 'late':
        return true;
      default:
        return false;
    }
  }

  bool get isAtRisk => absences >= 3;

  // == and hashCode let Flutter skip rebuilding a StudentAttendanceCard whose
  // data hasn't changed between poll ticks (works together with ValueKey).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStudent &&
          id == other.id &&
          isPresent == other.isPresent &&
          absences == other.absences;

  @override
  int get hashCode => Object.hash(id, isPresent, absences);
}
