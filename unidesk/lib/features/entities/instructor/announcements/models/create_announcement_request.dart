class CreateAnnouncementRequest {
  const CreateAnnouncementRequest({
    required this.courseId,
    required this.sectionId,
    required this.title,
    required this.type,
    required this.description,
  });

  final String courseId;
  final String sectionId;
  final String title;
  final String type;
  final String description;

  Map<String, dynamic> toApiFields() {
    return {
      'title': title,
      'type': _apiTypeFor(type),
      'description': description,
      'course_id': courseId,
      'section_id': sectionId,
    };
  }

  static String _apiTypeFor(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'assignment':
        return 'new_assignment';
      case 'exam':
        return 'exam_schedule';
      default:
        if (_validApiTypes.contains(normalized)) {
          return normalized;
        }
        return 'project_guidelines';
    }
  }

  static const Set<String> _validApiTypes = {
    'general',
    'project_guidelines',
    'new_assignment',
    'class_cancelled',
    'exam_schedule',
  };
}
