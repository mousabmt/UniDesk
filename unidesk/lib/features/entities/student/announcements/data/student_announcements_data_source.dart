import 'package:unidesk/features/entities/student/announcements/models/student_announcement.dart';

abstract class StudentAnnouncementsDataSource {
  Future<List<StudentAnnouncement>> getAnnouncements();
}

class StudentAnnouncementsDataSourceException implements Exception {
  const StudentAnnouncementsDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
