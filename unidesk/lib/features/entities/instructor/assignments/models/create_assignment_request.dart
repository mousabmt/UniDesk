import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';

class CreateAssignmentRequest {
  const CreateAssignmentRequest({
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.totalPoints,
    this.instructions,
    this.attachment,
  });

  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int totalPoints;
  final String? instructions;
  final AssignmentAttachment? attachment;

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'totalPoints': totalPoints,
      if (instructions != null && instructions!.trim().isNotEmpty)
        'instructions': instructions!.trim(),
      if (attachment != null) 'attachedFile': attachment!.toCreatePayload(),
    };
  }
}
