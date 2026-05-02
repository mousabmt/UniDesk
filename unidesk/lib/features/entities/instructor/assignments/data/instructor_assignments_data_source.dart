import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';

abstract class InstructorAssignmentsDataSource {
  Future<List<Assignment>> getAssignments({required String courseId});

  Future<List<AssignmentSubmission>> getAssignmentSubmissions({
    required String courseId,
    required String assignmentId,
  });

  Future<Assignment> createAssignment(CreateAssignmentRequest request);
}
