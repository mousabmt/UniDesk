import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';

class Assignment {
  const Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueDateLabel,
    required this.totalPoints,
    required this.submittedCount,
    required this.totalStudents,
    this.topic = '',
    this.instructions,
    this.attachment,
    this.status = 'active',
  });

  final String id;
  final String courseId;
  final String title;
  final String topic;
  final String description;
  final DateTime? dueDate;
  final String dueDateLabel;
  final int totalPoints;
  final String? instructions;
  final AssignmentAttachment? attachment;
  final int submittedCount;
  final int totalStudents;
  final String status;

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      topic: map['topic']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: _parseDate(map['dueDate']),
      dueDateLabel: map['dueDateLabel']?.toString() ?? '',
      totalPoints: _toInt(map['totalPoints']),
      instructions: map['instructions']?.toString(),
      attachment: map['attachedFile'] is Map
          ? AssignmentAttachment.fromMap(
              Map<String, dynamic>.from(map['attachedFile'] as Map),
            )
          : null,
      submittedCount: _toInt(map['submittedCount']),
      totalStudents: _toInt(map['totalStudents']),
      status: map['status']?.toString() ?? 'active',
    );
  }

  String get submissionRatioLabel => '$submittedCount/$totalStudents';

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
