class AttendanceCourse {
  const AttendanceCourse({
    required this.id,
    required this.name,
    required this.credits,
    required this.studentsEnrolled,
    required this.lectureId,
  });

  final String id;
  final String name;
  final int credits;
  final int studentsEnrolled;
  final String lectureId;

  factory AttendanceCourse.fromMap(Map<String, dynamic> map) {
    return AttendanceCourse(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Untitled Course',
      credits: (map['credits'] as num?)?.toInt() ?? 0,
      studentsEnrolled: (map['studentsEnrolled'] as num?)?.toInt() ?? 0,
      lectureId: map['lectureId']?.toString() ?? '',
    );
  }

  String get displayLabel => '$id - $name';
}
