import 'dart:typed_data';

import 'package:unidesk/core/services/mockApi.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

class MockInstructorCoursesDataSource implements InstructorCoursesDataSource {
  const MockInstructorCoursesDataSource();

  @override
  Future<InstructorCourseDetails> getCourseDetails({
    required String instructorId,
    required String courseId,
    String? sectionId,
  }) async {
    final response = await MockApi.getInstructorCourseDetails(
      instructorId: instructorId,
      courseId: courseId,
    );
    if (response['success'] != true) {
      throw InstructorCoursesRepositoryException(
        response['message']?.toString() ?? 'Failed to load course details',
      );
    }
    return InstructorCourseDetails.fromMap(
      Map<String, dynamic>.from(response['data'] ?? const {}),
    );
  }

  @override
  Future<List<InstructorManagedCourse>> getInstructorCourses(
    String instructorId,
  ) async {
    final response = await MockApi.getInstructorCourses(instructorId);
    if (response['success'] != true) {
      throw InstructorCoursesRepositoryException(
        response['message']?.toString() ?? 'Failed to load courses',
      );
    }
    return List<Map<String, dynamic>>.from(
      response['data'] ?? const [],
    ).map(InstructorManagedCourse.fromMap).toList();
  }

  @override
  Future<InstructorCourseFile> uploadCourseFile({
    required String instructorId,
    required String courseId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
    Uint8List? fileBytes,
  }) async {
    final response = await MockApi.uploadInstructorCourseFile(
      instructorId: instructorId,
      courseId: courseId,
      fileName: fileName,
      category: category.apiCategory,
      categoryId: category.categoryId,
      extensionLabel: extensionLabel,
      localPath: localPath,
    );
    if (response['success'] != true) {
      throw InstructorCoursesRepositoryException(
        response['message']?.toString() ?? 'Failed to upload course file',
      );
    }
    return InstructorCourseFile.fromMap(
      Map<String, dynamic>.from(response['data'] ?? const {}),
    );
  }
}
