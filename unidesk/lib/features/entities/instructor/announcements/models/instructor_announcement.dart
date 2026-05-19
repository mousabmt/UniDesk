class InstructorAnnouncement {
  const InstructorAnnouncement({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.courseId,
    required this.sectionId,
    this.content = '',
    this.createdAt,
    this.updatedAt,
  });

  factory InstructorAnnouncement.fromMap(Map<String, dynamic> map) {
    return InstructorAnnouncement(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString().trim() ?? '',
      type: map['type']?.toString().trim() ?? '',
      description: map['description']?.toString().trim() ?? '',
      content: map['content']?.toString().trim() ?? '',
      courseId: map['course_id']?.toString() ?? map['courseId']?.toString() ?? '',
      sectionId:
          map['section_id']?.toString() ?? map['sectionId']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? ''),
    );
  }

  final String id;
  final String title;
  final String type;
  final String description;
  final String content;
  final String courseId;
  final String sectionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get previewText {
    if (description.isNotEmpty) {
      return description;
    }
    return content;
  }
}
