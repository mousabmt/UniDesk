import 'package:intl/intl.dart';
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
      assignmentId:
          map['assignment_id']?.toString() ??
          map['assignmentId']?.toString() ??
          '',
      studentId:
          map['student_id']?.toString() ??
          map['studentId']?.toString() ??
          '',
      studentName:
          map['student_name']?.toString() ??
          map['studentName']?.toString() ??
          '',
      initials:
          map['initials']?.toString() ??
          _initialsFromName(
            map['student_name']?.toString() ??
                map['studentName']?.toString() ??
                '',
          ),
      status: map['status']?.toString() ?? 'submitted',
      submittedAt: DateTime.tryParse(
        map['submitted_at']?.toString() ?? map['submittedAt']?.toString() ?? '',
      ),
      submittedAtLabel:
          map['submittedAtLabel']?.toString() ??
          _formatSubmittedAt(
            map['submitted_at']?.toString() ?? map['submittedAt']?.toString(),
          ),
      file: map['file'] is Map
          ? AssignmentAttachment.fromMap(
              Map<String, dynamic>.from(map['file'] as Map),
            )
          : map['submission_file'] is Map
          ? AssignmentAttachment.fromMap(
              Map<String, dynamic>.from(map['submission_file'] as Map),
            )
          : null,
    );
  }

  static String _initialsFromName(String name) {
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final letters = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return letters;
  }

  static String _formatSubmittedAt(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return rawDate;
    }
    return DateFormat('MMM d, y').format(parsed.toLocal());
  }
}
