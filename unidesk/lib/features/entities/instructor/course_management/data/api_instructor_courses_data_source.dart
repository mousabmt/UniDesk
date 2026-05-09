import 'dart:typed_data';

import 'package:unidesk/core/services/student_api.dart';
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
    String? sectionId,
  }) async {
    try {
      final courses = await StudentApi.getInstructorCourses();
      Map<String, dynamic>? matchingCourse;
      for (final course in courses) {
        final candidateSectionId =
            course['sectionId']?.toString() ??
            course['lectureId']?.toString() ??
            '';
        if (course['id']?.toString() == courseId &&
            (sectionId == null ||
                sectionId.isEmpty ||
                candidateSectionId == sectionId)) {
          matchingCourse = course;
          break;
        }
      }

      if (matchingCourse == null) {
        throw const InstructorCoursesRepositoryException('Course not found');
      }

      final resolvedSectionId =
          matchingCourse['sectionId']?.toString() ??
          matchingCourse['lectureId']?.toString() ??
          '';
      final students = resolvedSectionId.isEmpty
          ? const <Map<String, dynamic>>[]
          : await StudentApi.getSectionStudents(sectionId: resolvedSectionId);
      final files = await StudentApi.getCourseFiles(courseId: courseId);

      final normalizedCourse = {
        ...matchingCourse,
        'studentsEnrolled': students.length,
      };

      return InstructorCourseDetails.fromMap({
        'course': normalizedCourse,
        'summary': {
          'averageAttendanceLabel': 'N/A',
          'assignmentsCount': 0,
          'filesCount': files.length,
        },
        'upcomingLecture': {
          'title': normalizedCourse['courseCode']?.toString().isNotEmpty == true
              ? '${normalizedCourse['courseCode']} lecture'
              : 'Upcoming class',
          'dateLabel': normalizedCourse['term']?.toString() ?? '',
          'timeLabel': normalizedCourse['teachingMode']?.toString() ?? '',
          'locationLabel':
              normalizedCourse['sectionLabel']?.toString().isNotEmpty == true
              ? 'Section ${normalizedCourse['sectionLabel']}'
              : '',
        },
        'files': files,
        'students': students,
      });
    } catch (error) {
      throw InstructorCoursesRepositoryException(error.toString());
    }
  }

  @override
  Future<List<InstructorManagedCourse>> getInstructorCourses(
    String instructorId,
  ) async {
    try {
      final courses = await StudentApi.getInstructorCourses();
      return courses.map((course) {
        return InstructorManagedCourse.fromMap(course);
      }).toList();
    } catch (error) {
      throw InstructorCoursesRepositoryException(error.toString());
    }
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
    final hasLocalPath = localPath != null && localPath.isNotEmpty;
    final hasBytes = fileBytes != null && fileBytes.isNotEmpty;
    if (!hasLocalPath && !hasBytes) {
      throw const InstructorCoursesRepositoryException(
        'Pick a local file before uploading.',
      );
    }

    try {
      final response = await StudentApi.uploadCourseFile(
        courseId: courseId,
        fileName: fileName,
        localPath: localPath,
        fileBytes: fileBytes,
      );
      return InstructorCourseFile.fromMap(response);
    } catch (error) {
      throw InstructorCoursesRepositoryException(error.toString());
    }
  }
}
