import 'dart:typed_data';

import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

abstract class InstructorCoursesDataSource {
  Future<List<InstructorManagedCourse>> getInstructorCourses(
    String instructorId,
  );
  Future<InstructorCourseDetails> getCourseDetails({
    required String instructorId,
    required String courseId,
    String? sectionId,
  });
  Future<InstructorCourseFile> uploadCourseFile({
    required String instructorId,
    required String courseId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
    Uint8List? fileBytes,
  });
}
