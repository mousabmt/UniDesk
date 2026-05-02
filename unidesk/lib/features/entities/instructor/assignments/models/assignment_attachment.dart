import 'package:flutter/material.dart';

class AssignmentAttachment {
  const AssignmentAttachment({
    required this.id,
    required this.name,
    required this.extensionLabel,
    required this.sizeLabel,
    this.url,
    this.localPath,
  });

  final String id;
  final String name;
  final String extensionLabel;
  final String sizeLabel;
  final String? url;
  final String? localPath;

  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;
  bool get hasRemoteUrl => url != null && url!.isNotEmpty;
  bool get canOpen => hasLocalFile || hasRemoteUrl;

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

  factory AssignmentAttachment.fromMap(Map<String, dynamic> map) {
    return AssignmentAttachment(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      extensionLabel: map['extensionLabel']?.toString() ?? 'FILE',
      sizeLabel: map['sizeLabel']?.toString() ?? '',
      url: map['url']?.toString(),
      localPath: map['localPath']?.toString(),
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'extensionLabel': extensionLabel,
      'sizeLabel': sizeLabel,
      if (localPath != null && localPath!.isNotEmpty) 'localPath': localPath,
    };
  }
}
