import 'package:flutter/material.dart';

class StudentCourseMaterial {
  const StudentCourseMaterial({
    required this.id,
    required this.courseId,
    required this.name,
    required this.fileType,
    required this.extensionLabel,
    required this.sizeLabel,
    required this.uploadedAtLabel,
    required this.uploadedBy,
    required this.downloadUrl,
    required this.category,
    this.description,
  });

  final String id;
  final String courseId;
  final String name;
  final String fileType;
  final String extensionLabel;
  final String sizeLabel;
  final String uploadedAtLabel;
  final String uploadedBy;
  final String downloadUrl;
  final String category;
  final String? description;

  bool get hasDownloadUrl => downloadUrl.isNotEmpty;
  bool get isExam => category == 'exam';
  bool get isMaterial => category == 'material' || category == 'lecture material';

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

  factory StudentCourseMaterial.fromMap(Map<String, dynamic> map) {
    return StudentCourseMaterial(
      id: map['id']?.toString() ?? '',
      courseId:
          map['courseId']?.toString() ?? map['course_id']?.toString() ?? '',
      name: map['name']?.toString() ?? map['file_name']?.toString() ?? '',
      fileType: map['file_type']?.toString() ?? '',
      extensionLabel: map['extensionLabel']?.toString() ?? 'FILE',
      sizeLabel: map['sizeLabel']?.toString() ?? '',
      uploadedAtLabel: map['uploadedAtLabel']?.toString() ?? '',
      uploadedBy: map['uploaded_by']?.toString() ?? '',
      downloadUrl:
          map['remoteUrl']?.toString() ??
          map['download_url']?.toString() ??
          map['file_url']?.toString() ??
          '',
      category: map['category']?.toString().trim().toLowerCase() ?? '',
      description: map['description']?.toString(),
    );
  }
}
