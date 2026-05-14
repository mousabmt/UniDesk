import 'package:intl/intl.dart';
import 'package:unidesk/features/entities/student/assignments/models/course_data.dart';
import 'package:unidesk/features/entities/student/assignments/models/file_data.dart';
import 'package:unidesk/features/entities/student/assignments/models/section_data.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_submission.dart';

class StudentAssignment {
  const StudentAssignment({
    required this.id,
    required this.courseId,
    required this.sectionId,
    required this.instructorId,
    required this.title,
    required this.description,
    required this.file,
    required this.dueDate,
    required this.maxScore,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.course,
    required this.section,
    this.submission,
  });

  final String id;
  final String courseId;
  final String sectionId;
  final String instructorId;
  final String title;
  final String description;
  final FileData? file;
  final String dueDate;
  final int maxScore;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final CourseData course;
  final SectionData section;
  final StudentSubmission? submission;

  bool get hasSubmission => submission != null;
  bool get isSubmitted => submission != null;
  bool get isGraded => submission?.isGraded ?? false;

  String get dueDateLabel {
    try {
      final parsed = DateTime.parse(dueDate);
      return DateFormat('MMM d, y - hh:mm a').format(parsed.toLocal());
    } catch (e) {
      return dueDate;
    }
  }

  DateTime? get dueDateParsed {
    try {
      return DateTime.parse(dueDate);
    } catch (e) {
      return null;
    }
  }

  bool get isOverdue {
    final due = dueDateParsed;
    if (due == null) return false;
    return DateTime.now().isAfter(due);
  }

  String get statusLabel {
    if (!isActive) return 'Inactive';
    if (isSubmitted) {
      if (isGraded) {
        return 'Graded';
      }
      return 'Submitted';
    }
    if (isOverdue) {
      return 'Overdue';
    }
    return 'Active';
  }

  factory StudentAssignment.fromMap(Map<String, dynamic> map) {
    final fileData = map['file'] is Map<String, dynamic>
        ? FileData.fromMap(Map<String, dynamic>.from(map['file']))
        : null;

    final submissionData = map['submission'] is Map<String, dynamic>
        ? StudentSubmission.fromMap(Map<String, dynamic>.from(map['submission']))
        : null;

    final courseData = map['course'] is Map<String, dynamic>
        ? CourseData.fromMap(Map<String, dynamic>.from(map['course']))
        : CourseData(id: '', courseName: '', courseCode: '');

    final sectionData = map['section'] is Map<String, dynamic>
        ? SectionData.fromMap(Map<String, dynamic>.from(map['section']))
        : SectionData(id: '', sectionNumber: 0);

    return StudentAssignment(
      id: map['id']?.toString() ?? '',
      courseId: map['course_id']?.toString() ?? '',
      sectionId: map['section_id']?.toString() ?? '',
      instructorId: map['instructor_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      file: fileData,
      dueDate: map['due_date']?.toString() ?? '',
      maxScore: _toInt(map['max_score']),
      isActive: _toBool(map['is_active']),
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
      course: courseData,
      section: sectionData,
      submission: submissionData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'section_id': sectionId,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'file': file?.toMap(),
      'due_date': dueDate,
      'max_score': maxScore,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'course': course.toMap(),
      'section': section.toMap(),
      'submission': submission?.toMap(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}
