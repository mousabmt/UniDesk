class StudentAnnouncement {
  const StudentAnnouncement({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.content,
    required this.link,
    required this.isPublished,
    required this.createdBy,
    required this.creatorName,
    required this.courseId,
    required this.sectionId,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  factory StudentAnnouncement.fromMap(Map<String, dynamic> map) {
    return StudentAnnouncement(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString().trim() ?? '',
      type: map['type']?.toString().trim() ?? '',
      description: map['description']?.toString().trim() ?? '',
      content: map['content']?.toString().trim() ?? '',
      link: _nullableValue(map['link']),
      isPublished: map['is_published'] == true,
      createdBy: map['created_by']?.toString() ?? '',
      creatorName: map['creator_name']?.toString().trim() ?? '',
      courseId: map['course_id']?.toString() ?? '',
      sectionId: map['section_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? ''),
      imageUrl: _nullableValue(map['imageUrl'] ?? map['image_url']),
    );
  }

  final String id;
  final String title;
  final String type;
  final String description;
  final String content;
  final String? link;
  final bool isPublished;
  final String createdBy;
  final String creatorName;
  final String courseId;
  final String sectionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;

  String get badgeLabel {
    final normalized = type.trim().replaceAll('_', ' ');
    if (normalized.isEmpty) {
      return 'Update';
    }
    return normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String get previewText {
    if (description.isNotEmpty) {
      return description;
    }
    if (content.isNotEmpty) {
      return content;
    }
    return 'Stay updated with the latest course announcement.';
  }

  bool get hasLink => link != null && link!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  static String? _nullableValue(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
