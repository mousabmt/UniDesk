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
    this.score,
    this.feedback,
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
  final double? score;
  final String? feedback;

  bool get isSubmitted {
    final normalized = status.toLowerCase();
    return normalized == 'submitted' || normalized == 'graded';
  }
  bool get isGraded => score != null;
  String get scoreLabel => score == null ? 'Ungraded' : _formatScore(score!);

  factory AssignmentSubmission.fromMap(Map<String, dynamic> map) {
    // Parse file from various possible keys
    AssignmentAttachment? parsedFile;
    if (map['file'] is Map) {
      parsedFile = AssignmentAttachment.fromMap(
        Map<String, dynamic>.from(map['file'] as Map),
      );
    } else if (map['submission_file'] is Map) {
      parsedFile = AssignmentAttachment.fromMap(
        Map<String, dynamic>.from(map['submission_file'] as Map),
      );
    }
    
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
      file: parsedFile,
      score: _toDoubleOrNull(map['score'] ?? map['grade']),
      feedback: map['feedback']?.toString(),
    );
  }

  AssignmentSubmission copyWith({
    String? status,
    AssignmentAttachment? file,
    double? score,
    String? feedback,
    bool keepExistingFile = true,
  }) {
    return AssignmentSubmission(
      id: id,
      assignmentId: assignmentId,
      studentId: studentId,
      studentName: studentName,
      initials: initials,
      status: status ?? this.status,
      submittedAt: submittedAt,
      submittedAtLabel: submittedAtLabel,
      file: keepExistingFile ? (file ?? this.file) : file,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
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

  static String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
