import 'package:intl/intl.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_attachment.dart';

class Assignment {
  const Assignment({
    required this.id,
    required this.courseId,
    required this.sectionId,
    required this.instructorId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxScore,
    required this.isActive,
    this.filePath,
    this.fileUrl,
    this.fileName,
  });

  final String id;
  final String courseId;
  final String sectionId;
  final String instructorId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final int maxScore;
  final bool isActive;
  final String? filePath;
  final String? fileUrl;
  final String? fileName;

  factory Assignment.fromMap(Map<String, dynamic> map) {
    final nestedFile = map['file'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(map['file'] as Map<String, dynamic>)
        : map['file'] is Map
        ? Map<String, dynamic>.from(map['file'] as Map)
        : null;
    return Assignment(
      id: map['id']?.toString() ?? '',
      courseId:
          map['course_id']?.toString() ?? map['courseId']?.toString() ?? '',
      sectionId:
          map['section_id']?.toString() ?? map['sectionId']?.toString() ?? '',
      instructorId:
          map['instructor_id']?.toString() ??
          map['instructorId']?.toString() ??
          '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: _parseDate(map['due_date'] ?? map['dueDate']),
      maxScore: _toInt(map['max_score'] ?? map['totalPoints']),
      filePath:
          map['file_path']?.toString() ?? nestedFile?['file_path']?.toString(),
      fileUrl:
          map['file_url']?.toString() ?? nestedFile?['file_url']?.toString(),
      fileName:
          map['file_name']?.toString() ?? nestedFile?['file_name']?.toString(),
    );
  }

  AssignmentAttachment? get attachment => _attachmentFromStoredValues(
    filePath: filePath,
    fileUrl: fileUrl,
    fileName: fileName,
    title: title,
  );

  String get dueDateLabel {
    if (dueDate == null) {
      return '';
    }
    return DateFormat('MMM d, y').format(dueDate!.toLocal());
  }

  String get statusLabel => isActive ? 'Active' : 'Inactive';

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static AssignmentAttachment? _attachmentFromStoredValues({
    required String? filePath,
    required String? fileUrl,
    required String? fileName,
    required String title,
  }) {
    final resolvedUrl = fileUrl?.trim();
    final resolvedPath = filePath?.trim();
    if ((resolvedUrl == null || resolvedUrl.isEmpty) &&
        (resolvedPath == null || resolvedPath.isEmpty)) {
      return null;
    }
    final rawName =
        fileName != null && fileName.trim().isNotEmpty
        ? fileName.trim()
        : _fileNameFromPath(resolvedPath ?? resolvedUrl ?? title);
    return AssignmentAttachment(
      id: '',
      name: rawName,
      extensionLabel: _fileExtension(rawName),
      sizeLabel: '',
      url: resolvedUrl,
      localPath: resolvedPath,
    );
  }

  static String _fileNameFromPath(String value) {
    final normalized = value.replaceAll('\\', '/');
    final last = normalized.split('/').last.trim();
    return last.isEmpty ? 'attachment' : last;
  }

  static String _fileExtension(String value) {
    if (!value.contains('.')) {
      return 'FILE';
    }
    final extension = value.split('.').last.trim();
    return extension.isEmpty ? 'FILE' : extension.toUpperCase();
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == '1' ||
      normalized == 'true' ||
      normalized == 'active' ||
      normalized == 'yes';
}
