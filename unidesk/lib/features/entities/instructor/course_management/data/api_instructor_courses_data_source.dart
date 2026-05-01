import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

class ApiInstructorCoursesDataSource implements InstructorCoursesDataSource {
  const ApiInstructorCoursesDataSource();

  @override
  Future<InstructorCourseDetails> getCourseDetails({
    required String instructorId,
    required String courseId,
  }) {
    throw const InstructorCoursesRepositoryException(
      'Instructor courses API is not connected yet.',
    );
  }

  @override
  Future<List<InstructorManagedCourse>> getInstructorCourses(String instructorId) {
    throw const InstructorCoursesRepositoryException(
      'Instructor courses API is not connected yet.',
    );
  }

  @override
  Future<InstructorCourseFile> uploadCourseFile({
    required String instructorId,
    required String courseId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
  }) {
    throw const InstructorCoursesRepositoryException(
      'Instructor courses API is not connected yet.',
    );
  }
}
