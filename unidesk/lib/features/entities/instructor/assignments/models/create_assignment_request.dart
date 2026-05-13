import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';

class CreateAssignmentRequest {
  const CreateAssignmentRequest({
    required this.courseId,
    required this.sectionId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxScore,
    this.isActive = true,
    this.category_id,
    this.attachment,
  });

  final String courseId;
  final String sectionId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxScore;
  final bool isActive;
  final int? category_id;
  final AssignmentAttachment? attachment;

Map<String, dynamic> toApiFields() {
  return {
    'course_id': courseId,
    'section_id': sectionId,
    'title': title,
    'description': description,
    'due_date': _formatApiDateTime(dueDate),
    'max_score': maxScore,
    'category_id': category_id ?? 3,
  };
}

  static String _formatApiDateTime(DateTime value) {
    final normalized = value.toLocal();
    final twoDigits = (int number) => number.toString().padLeft(2, '0');
    return '${normalized.year}-'
        '${twoDigits(normalized.month)}-'
        '${twoDigits(normalized.day)} '
        '${twoDigits(normalized.hour)}:'
        '${twoDigits(normalized.minute)}:'
        '${twoDigits(normalized.second)}';
  }
}
