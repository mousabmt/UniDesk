import 'package:unidesk/features/entities/instructor/announcements/data/instructor_announcements_data_source.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/create_announcement_request.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/instructor_announcement.dart';

abstract class InstructorAnnouncementsRepository {
  Future<List<InstructorAnnouncement>> getAnnouncements();

  Future<InstructorAnnouncement> createAnnouncement(
    CreateAnnouncementRequest request,
  );
}

class InstructorAnnouncementsRepositoryImpl
    implements InstructorAnnouncementsRepository {
  const InstructorAnnouncementsRepositoryImpl(this._dataSource);

  final InstructorAnnouncementsDataSource _dataSource;

  @override
  Future<List<InstructorAnnouncement>> getAnnouncements() {
    return _dataSource.getAnnouncements();
  }

  @override
  Future<InstructorAnnouncement> createAnnouncement(
    CreateAnnouncementRequest request,
  ) {
    return _dataSource.createAnnouncement(request);
  }
}

class InstructorAnnouncementsRepositoryException implements Exception {
  const InstructorAnnouncementsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
