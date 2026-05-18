import 'package:unidesk/features/entities/student/announcements/data/student_announcements_data_source.dart';
import 'package:unidesk/features/entities/student/announcements/models/student_announcement.dart';

abstract class StudentAnnouncementsRepository {
  Future<List<StudentAnnouncement>> getAnnouncements();
}

class StudentAnnouncementsRepositoryImpl
    implements StudentAnnouncementsRepository {
  const StudentAnnouncementsRepositoryImpl(this._dataSource);

  final StudentAnnouncementsDataSource _dataSource;

  @override
  Future<List<StudentAnnouncement>> getAnnouncements() {
    return _dataSource.getAnnouncements();
  }
}

class StudentAnnouncementsRepositoryException implements Exception {
  const StudentAnnouncementsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
