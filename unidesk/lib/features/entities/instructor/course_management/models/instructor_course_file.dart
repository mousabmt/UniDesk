import 'package:flutter/material.dart';

enum InstructorCourseFileCategory {
  lecture,
  assignment,
  exam,
  other,
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
  });

  final String id;
  final String courseId;
  final String name;
  final String extensionLabel;
  final String sizeLabel;
  final String uploadedAtLabel;
  final InstructorCourseFileCategory category;
  final String? localPath;

  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;

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
      category: _parseCategory(map['category']?.toString()),
      localPath: map['localPath']?.toString(),
    );
  }

  static InstructorCourseFileCategory _parseCategory(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'lecture':
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
