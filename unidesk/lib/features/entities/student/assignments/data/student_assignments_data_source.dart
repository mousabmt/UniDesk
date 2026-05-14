import 'package:unidesk/features/entities/student/assignments/models/student_assignment.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_submission.dart';

abstract class StudentAssignmentsDataSource {
  Future<List<StudentAssignment>> getAssignments();

  Future<StudentAssignment> getAssignmentDetail(String assignmentId);

  Future<StudentSubmission> submitAssignment({
    required String assignmentId,
    required String fileName,
    required String localPath,
  });

  Future<List<StudentSubmission>> getSubmissions();
}

class StudentAssignmentsDataSourceException implements Exception {
  const StudentAssignmentsDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
