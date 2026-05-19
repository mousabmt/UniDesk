import 'package:unidesk/features/entities/instructor/announcements/models/create_announcement_request.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/instructor_announcement.dart';

abstract class InstructorAnnouncementsDataSource {
  Future<List<InstructorAnnouncement>> getAnnouncements();

  Future<InstructorAnnouncement> createAnnouncement(
    CreateAnnouncementRequest request,
  );
}

class InstructorAnnouncementsDataSourceException implements Exception {
  const InstructorAnnouncementsDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
