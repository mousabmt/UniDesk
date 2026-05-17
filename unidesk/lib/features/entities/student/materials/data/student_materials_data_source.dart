import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';

abstract class StudentMaterialsDataSource {
  Future<List<StudentCourseMaterial>> getMaterialsByCourse(String courseId);
}

class StudentMaterialsDataSourceException implements Exception {
  const StudentMaterialsDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
