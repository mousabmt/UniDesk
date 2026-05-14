class CourseData {
  const CourseData({
    required this.id,
    required this.courseName,
    required this.courseCode,
  });

  final String id;
  final String courseName;
  final String courseCode;

  factory CourseData.fromMap(Map<String, dynamic> map) {
    return CourseData(
      id: map['id']?.toString() ?? '',
      courseName: map['course_name']?.toString() ?? '',
      courseCode: map['course_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_name': courseName,
      'course_code': courseCode,
    };
  }
}
