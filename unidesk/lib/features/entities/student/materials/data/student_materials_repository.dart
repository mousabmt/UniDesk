import 'package:unidesk/features/entities/student/materials/data/student_materials_data_source.dart';
import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';

abstract class StudentMaterialsRepository {
  Future<List<StudentCourseMaterial>> getMaterialsByCourse(String courseId);
}

class StudentMaterialsRepositoryImpl implements StudentMaterialsRepository {
  const StudentMaterialsRepositoryImpl(this._dataSource);

  final StudentMaterialsDataSource _dataSource;

  @override
  Future<List<StudentCourseMaterial>> getMaterialsByCourse(String courseId) {
    return _dataSource.getMaterialsByCourse(courseId);
  }
}

class StudentMaterialsRepositoryException implements Exception {
  const StudentMaterialsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
