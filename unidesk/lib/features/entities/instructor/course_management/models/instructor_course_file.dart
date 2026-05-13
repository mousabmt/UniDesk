import 'package:flutter/material.dart';

enum InstructorCourseFileCategory {
  lecture,
  assignment,
  exam,
  other,
}

extension InstructorCourseFileCategoryX on InstructorCourseFileCategory {
  int get categoryId {
    switch (this) {
      case InstructorCourseFileCategory.assignment:
        return 1;
      case InstructorCourseFileCategory.exam:
        return 2;
      case InstructorCourseFileCategory.lecture:
        return 3;
      case InstructorCourseFileCategory.other:
        return 0;
    }
  }

  String get apiCategory {
    switch (this) {
      case InstructorCourseFileCategory.assignment:
        return 'assignment';
      case InstructorCourseFileCategory.exam:
        return 'exam';
      case InstructorCourseFileCategory.lecture:
        return 'material';
      case InstructorCourseFileCategory.other:
        return 'other';
    }
  }
}

class InstructorCourseFile {
  const InstructorCourseFile({
    required this.id,
    required this.courseId,
    required this.name,
    required this.extensionLabel,
    required this.sizeLabel,
    required this.uploadedAtLabel,
    required this.category,
    this.localPath,
    this.remoteUrl,
  });

  final String id;
  final String courseId;
  final String name;
  final String extensionLabel;
  final String sizeLabel;
  final String uploadedAtLabel;
  final InstructorCourseFileCategory category;
  final String? localPath;
  final String? remoteUrl;

  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;
  bool get hasRemoteFile => remoteUrl != null && remoteUrl!.isNotEmpty;

  Color get badgeColor {
    switch (extensionLabel.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'PPTX':
        return Colors.orange;
      case 'DOCX':
        return Colors.blue;
      default:
        return const Color(0xff0bb4b1);
    }
  }

  factory InstructorCourseFile.fromMap(Map<String, dynamic> map) {
    return InstructorCourseFile(
      id: map['id']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      extensionLabel: map['extensionLabel']?.toString() ?? 'FILE',
      sizeLabel: map['sizeLabel']?.toString() ?? '',
      uploadedAtLabel: map['uploadedAtLabel']?.toString() ?? '',
      category: _parseCategory(
        map['category']?.toString(),
        categoryId: map['category_id'],
      ),
      localPath: map['localPath']?.toString(),
      remoteUrl:
          map['remoteUrl']?.toString() ??
          map['download_url']?.toString() ??
          map['file_url']?.toString(),
    );
  }

  static InstructorCourseFileCategory _parseCategory(
    String? raw, {
    dynamic categoryId,
  }) {
    final parsedId = int.tryParse(categoryId?.toString() ?? '');
    switch (parsedId) {
      case 1:
        return InstructorCourseFileCategory.assignment;
      case 2:
        return InstructorCourseFileCategory.exam;
      case 3:
        return InstructorCourseFileCategory.lecture;
    }
    switch (raw?.toLowerCase()) {
      case 'lecture':
      case 'material':
        return InstructorCourseFileCategory.lecture;
      case 'assignment':
        return InstructorCourseFileCategory.assignment;
      case 'exam':
        return InstructorCourseFileCategory.exam;
      default:
        return InstructorCourseFileCategory.other;
    }
  }
}
