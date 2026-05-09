class InstructorManagedCourse {
  const InstructorManagedCourse({
    required this.id,
    required this.name,
    required this.credits,
    required this.studentsEnrolled,
    required this.lectureId,
    this.courseCode = '',
    this.sectionId = '',
    this.term = '',
    this.sectionLabel = '',
    this.teachingMode = '',
    this.semesterId = '',
  });

  final String id;
  final String name;
  final int credits;
  final int studentsEnrolled;
  final String lectureId;
  final String courseCode;
  final String sectionId;
  final String term;
  final String sectionLabel;
  final String teachingMode;
  final String semesterId;

  String get displayLabel =>
      '${courseCode.isNotEmpty ? courseCode : id} - $name';
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

  factory InstructorManagedCourse.fromMap(Map<String, dynamic> map) {
    return InstructorManagedCourse(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      credits: _toInt(map['credits']),
      studentsEnrolled: _toInt(map['studentsEnrolled']),
      lectureId: map['lectureId']?.toString() ?? '',
      courseCode: map['courseCode']?.toString() ?? '',
      sectionId: map['sectionId']?.toString() ?? '',
      term: map['term']?.toString() ?? '',
      sectionLabel: map['sectionLabel']?.toString() ?? '',
      teachingMode: map['teachingMode']?.toString() ?? '',
      semesterId: map['semesterId']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

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
