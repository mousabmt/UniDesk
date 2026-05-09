class AttendanceCourse {
  const AttendanceCourse({
    required this.id,
    required this.name,
    required this.credits,
    required this.studentsEnrolled,
    required this.lectureId,
    this.courseCode = '',
    this.sectionId = '',
    this.teachingMode = '',
  });

  final String id;
  final String name;
  final int credits;
  final int studentsEnrolled;
  final String lectureId;
  final String courseCode;
  final String sectionId;
  final String teachingMode;

  String get selectionKey => _selectionKeyFor(
    courseId: id,
    sectionId: sectionId,
    lectureId: lectureId,
  );

  bool matchesSelection(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return selectionKey == value || id == value;
  }

  factory AttendanceCourse.fromMap(Map<String, dynamic> map) {
    return AttendanceCourse(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Untitled Course',
      credits: (map['credits'] as num?)?.toInt() ?? 0,
      studentsEnrolled: (map['studentsEnrolled'] as num?)?.toInt() ?? 0,
      lectureId: map['lectureId']?.toString() ?? '',
      courseCode: map['courseCode']?.toString() ?? '',
      sectionId: map['sectionId']?.toString() ?? '',
      teachingMode: map['teachingMode']?.toString() ?? '',
    );
  }

  String get displayLabel =>
      '${courseCode.isNotEmpty ? courseCode : id} - $name';

  static String _selectionKeyFor({
    required String courseId,
    required String sectionId,
    required String lectureId,
  }) {
    final scopeId = sectionId.isNotEmpty ? sectionId : lectureId;
    if (scopeId.isEmpty) {
      return courseId;
    }
    return '$courseId::$scopeId';
  }
}
