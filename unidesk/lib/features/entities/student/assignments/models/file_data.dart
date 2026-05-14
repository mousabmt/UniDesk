class FileData {
  const FileData({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
    required this.description,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  final String id;
  final String fileName;
  final String filePath;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final String description;
  final String uploadedBy;
  final String uploadedAt;

  factory FileData.fromMap(Map<String, dynamic> map) {
    return FileData(
      id: map['id']?.toString() ?? '',
      fileName: map['file_name']?.toString() ?? '',
      filePath: map['file_path']?.toString() ?? '',
      fileUrl: map['file_url']?.toString() ?? '',
      fileSize: _toInt(map['file_size']),
      fileType: map['file_type']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      uploadedBy: map['uploaded_by']?.toString() ?? '',
      uploadedAt: map['uploaded_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_type': fileType,
      'description': description,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
