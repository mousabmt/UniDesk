import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/entities/student/materials/data/student_materials_data_source.dart';
import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';

class ApiStudentMaterialsDataSource implements StudentMaterialsDataSource {
  const ApiStudentMaterialsDataSource();

  @override
  Future<List<StudentCourseMaterial>> getMaterialsByCourse(
    String courseId,
  ) async {
    try {
      final response = await StudentApi.getStudentMaterialsByCourse(
        courseId: courseId,
      );
      return response.map(StudentCourseMaterial.fromMap).toList();
    } catch (error) {
      throw StudentMaterialsDataSourceException(error.toString());
    }
  }
}
