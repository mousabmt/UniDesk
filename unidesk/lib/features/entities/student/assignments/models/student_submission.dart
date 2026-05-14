import 'package:intl/intl.dart';

class StudentSubmission {
  const StudentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.fileUrl,
    required this.score,
    required this.feedback,
    required this.submittedAt,
  });

  final String id;
  final String assignmentId;
  final String studentId;
  final String fileUrl;
  final int? score;
  final String? feedback;
  final String submittedAt;

  bool get isGraded => score != null;

  String get submittedAtLabel {
    try {
      final parsed = DateTime.parse(submittedAt);
      return DateFormat('MMM d, y - hh:mm a').format(parsed.toLocal());
    } catch (e) {
      return submittedAt;
    }
  }

  factory StudentSubmission.fromMap(Map<String, dynamic> map) {
    return StudentSubmission(
      id: map['id']?.toString() ?? '',
      assignmentId: map['assignment_id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      fileUrl: map['file_url']?.toString() ?? '',
      score: _toIntOrNull(map['score']),
      feedback: map['feedback']?.toString(),
      submittedAt: map['submitted_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'file_url': fileUrl,
      'score': score,
      'feedback': feedback,
      'submitted_at': submittedAt,
    };
  }

  static int? _toIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
