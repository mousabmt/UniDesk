import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/entities/instructor/announcements/data/instructor_announcements_data_source.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/create_announcement_request.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/instructor_announcement.dart';

class ApiInstructorAnnouncementsDataSource
    implements InstructorAnnouncementsDataSource {
  const ApiInstructorAnnouncementsDataSource();

  @override
  Future<List<InstructorAnnouncement>> getAnnouncements() async {
    try {
      final response = await StudentApi.getInstructorAnnouncements();
      return response.map(InstructorAnnouncement.fromMap).toList();
    } catch (error) {
      throw InstructorAnnouncementsDataSourceException(error.toString());
    }
  }

  @override
  Future<InstructorAnnouncement> createAnnouncement(
    CreateAnnouncementRequest request,
  ) async {
    try {
      final response = await StudentApi.createInstructorAnnouncement(
        fields: request.toApiFields(),
      );
      return InstructorAnnouncement.fromMap(response);
    } catch (error) {
      throw InstructorAnnouncementsDataSourceException(error.toString());
    }
  }
}
