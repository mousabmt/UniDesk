import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';

class AssignmentSubmission {
  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.initials,
    required this.status,
    this.submittedAt,
    this.submittedAtLabel = '',
    this.file,
  });

  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String initials;
  final String status;
  final DateTime? submittedAt;
  final String submittedAtLabel;
  final AssignmentAttachment? file;

  bool get isSubmitted => status.toLowerCase() == 'submitted';

  factory AssignmentSubmission.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmission(
      id: map['id']?.toString() ?? '',
      assignmentId: map['assignmentId']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      studentName: map['studentName']?.toString() ?? '',
      initials: map['initials']?.toString() ?? '',
      status: map['status']?.toString() ?? 'submitted',
      submittedAt: DateTime.tryParse(map['submittedAt']?.toString() ?? ''),
      submittedAtLabel: map['submittedAtLabel']?.toString() ?? '',
      file: map['file'] is Map
          ? AssignmentAttachment.fromMap(
              Map<String, dynamic>.from(map['file'] as Map),
            )
          : null,
    );
  }
}
