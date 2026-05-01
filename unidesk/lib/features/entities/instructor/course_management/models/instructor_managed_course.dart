class InstructorManagedCourse {
  const InstructorManagedCourse({
    required this.id,
    required this.name,
    required this.credits,
    required this.studentsEnrolled,
    required this.lectureId,
    this.term = '',
    this.sectionLabel = '',
  });

  final String id;
  final String name;
  final int credits;
  final int studentsEnrolled;
  final String lectureId;
  final String term;
  final String sectionLabel;

  String get displayLabel => '$id - $name';

  factory InstructorManagedCourse.fromMap(Map<String, dynamic> map) {
    return InstructorManagedCourse(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      credits: _toInt(map['credits']),
      studentsEnrolled: _toInt(map['studentsEnrolled']),
      lectureId: map['lectureId']?.toString() ?? '',
      term: map['term']?.toString() ?? '',
      sectionLabel: map['sectionLabel']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
