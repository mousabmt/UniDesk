import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/entities/student/announcements/data/student_announcements_data_source.dart';
import 'package:unidesk/features/entities/student/announcements/models/student_announcement.dart';

class ApiStudentAnnouncementsDataSource
    implements StudentAnnouncementsDataSource {
  const ApiStudentAnnouncementsDataSource();

  @override
  Future<List<StudentAnnouncement>> getAnnouncements() async {
    try {
      final response = await StudentApi.getAds();
      return response.map(StudentAnnouncement.fromMap).toList();
    } catch (error) {
      throw StudentAnnouncementsDataSourceException(error.toString());
    }
  }
}
