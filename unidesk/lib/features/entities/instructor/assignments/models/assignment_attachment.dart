import 'dart:typed_data';

import 'package:flutter/material.dart';

class AssignmentAttachment {
  const AssignmentAttachment({
    required this.id,
    required this.name,
    required this.extensionLabel,
    required this.sizeLabel,
    this.url,
    this.localPath,
    this.bytes,
  });

  final String id;
  final String name;
  final String extensionLabel;
  final String sizeLabel;
  final String? url;
  final String? localPath;
  final Uint8List? bytes;

  bool get hasLocalFile => _looksLikeLocalPath(localPath);
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
    final name =
        map['name']?.toString() ??
        map['file_name']?.toString() ??
        map['original_name']?.toString() ??
        '';
    final extension =
        map['extensionLabel']?.toString() ??
        map['extension_label']?.toString() ??
        _extensionFromName(name);
    final sizeLabel = _formatFileSize(
      map['sizeLabel']?.toString(),
      map['size_label']?.toString(),
      map['file_size'],
    );
    return AssignmentAttachment(
      id: map['id']?.toString() ?? '',
      name: name,
      extensionLabel: extension,
      sizeLabel: sizeLabel,
      url:
          map['url']?.toString() ??
          map['file_url']?.toString() ??
          map['download_url']?.toString(),
      localPath: map['localPath']?.toString(),
      bytes: null,
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

  static String _extensionFromName(String name) {
    if (!name.contains('.')) {
      return 'FILE';
    }
    final extension = name.split('.').last.trim();
    return extension.isEmpty ? 'FILE' : extension.toUpperCase();
  }

  static bool _looksLikeLocalPath(String? value) {
    if (value == null) {
      return false;
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return false;
    }
    if (normalized.startsWith('file://')) {
      return true;
    }
    if (normalized.startsWith('/') || normalized.startsWith('\\')) {
      return true;
    }
    final windowsDrive = RegExp(r'^[a-zA-Z]:[\\/]');
    return windowsDrive.hasMatch(normalized);
  }

  static String _formatFileSize(
    String? formattedLabel,
    String? sizeLabel,
    dynamic rawSize,
  ) {
    if (formattedLabel != null && formattedLabel.isNotEmpty) {
      return formattedLabel;
    }
    if (sizeLabel != null && sizeLabel.isNotEmpty) {
      return sizeLabel;
    }
    final bytes =
        rawSize is num ? rawSize.toDouble() : double.tryParse(rawSize?.toString() ?? '');
    if (bytes == null || bytes <= 0) {
      return '';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes;
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final decimals = unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }
}
