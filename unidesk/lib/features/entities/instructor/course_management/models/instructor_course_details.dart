import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

class InstructorCourseDetails {
  const InstructorCourseDetails({
    required this.course,
    required this.summary,
    required this.upcomingLecture,
    required this.files,
    required this.students,
  });

  final InstructorManagedCourse course;
  final InstructorCourseSummary summary;
  final InstructorUpcomingLecture upcomingLecture;
  final List<InstructorCourseFile> files;
  final List<InstructorCourseStudent> students;

  factory InstructorCourseDetails.fromMap(Map<String, dynamic> map) {
    return InstructorCourseDetails(
      course: InstructorManagedCourse.fromMap(
        Map<String, dynamic>.from(map['course'] ?? const {}),
      ),
      summary: InstructorCourseSummary.fromMap(
        Map<String, dynamic>.from(map['summary'] ?? const {}),
      ),
      upcomingLecture: InstructorUpcomingLecture.fromMap(
        Map<String, dynamic>.from(map['upcomingLecture'] ?? const {}),
      ),
      files: List<Map<String, dynamic>>.from(map['files'] ?? const [])
          .map(InstructorCourseFile.fromMap)
          .toList(),
      students: List<Map<String, dynamic>>.from(map['students'] ?? const [])
          .map(InstructorCourseStudent.fromMap)
          .toList(),
    );
  }
}

class InstructorCourseSummary {
  const InstructorCourseSummary({
    required this.averageAttendanceLabel,
    required this.assignmentsCount,
    required this.filesCount,
  });

  final String averageAttendanceLabel;
  final int assignmentsCount;
  final int filesCount;

  factory InstructorCourseSummary.fromMap(Map<String, dynamic> map) {
    return InstructorCourseSummary(
      averageAttendanceLabel:
          map['averageAttendanceLabel']?.toString() ?? '0%',
      assignmentsCount: _toInt(map['assignmentsCount']),
      filesCount: _toInt(map['filesCount']),
    );
  }
}

class InstructorUpcomingLecture {
  const InstructorUpcomingLecture({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.locationLabel,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final String locationLabel;

  factory InstructorUpcomingLecture.fromMap(Map<String, dynamic> map) {
    return InstructorUpcomingLecture(
      title: map['title']?.toString() ?? '',
      dateLabel: map['dateLabel']?.toString() ?? '',
      timeLabel: map['timeLabel']?.toString() ?? '',
      locationLabel: map['locationLabel']?.toString() ?? '',
    );
  }
}

class InstructorCourseStudent {
  const InstructorCourseStudent({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory InstructorCourseStudent.fromMap(Map<String, dynamic> map) {
    return InstructorCourseStudent(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
