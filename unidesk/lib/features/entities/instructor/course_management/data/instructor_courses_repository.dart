import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

abstract class InstructorCoursesRepository {
  Future<List<InstructorManagedCourse>> getInstructorCourses(String instructorId);
  Future<InstructorCourseDetails> getCourseDetails({
    required String instructorId,
    required String courseId,
  });
  Future<InstructorCourseFile> uploadCourseFile({
    required String instructorId,
    required String courseId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
  });
}

class InstructorCoursesRepositoryImpl implements InstructorCoursesRepository {
  const InstructorCoursesRepositoryImpl(this._dataSource);

  final InstructorCoursesDataSource _dataSource;

  @override
  Future<List<InstructorManagedCourse>> getInstructorCourses(
    String instructorId,
  ) {
    return _dataSource.getInstructorCourses(instructorId);
  }

  @override
  Future<InstructorCourseDetails> getCourseDetails({
    required String instructorId,
    required String courseId,
  }) {
    return _dataSource.getCourseDetails(
      instructorId: instructorId,
      courseId: courseId,
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
    return _dataSource.uploadCourseFile(
      instructorId: instructorId,
      courseId: courseId,
      fileName: fileName,
      category: category,
      extensionLabel: extensionLabel,
      localPath: localPath,
    );
  }
}

class InstructorCoursesRepositoryException implements Exception {
  const InstructorCoursesRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
