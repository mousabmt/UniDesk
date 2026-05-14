import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_repository.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';

class ApiInstructorAssignmentsDataSource
    implements InstructorAssignmentsDataSource {
  const ApiInstructorAssignmentsDataSource();

  @override
  Future<List<Assignment>> getAssignments() async {
    try {
      final response = await StudentApi.getInstructorAssignments();
      return response.map(Assignment.fromMap).toList();
    } catch (error) {
      throw InstructorAssignmentsRepositoryException(error.toString());
    }
  }

  @override
  Future<List<AssignmentSubmission>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    try {
      final response = await StudentApi.getAssignmentSubmissions(
        assignmentId: assignmentId,
      );
      return response.map(AssignmentSubmission.fromMap).toList();
    } catch (error) {
      throw InstructorAssignmentsRepositoryException(error.toString());
    }
  }

  @override
  Future<Assignment> createAssignment(CreateAssignmentRequest request) async {
    try {
      final response = await StudentApi.createInstructorAssignment(
        fields: request.toApiFields(),
        fileName: request.attachment?.name,
        localPath: request.attachment?.localPath,
        fileBytes: request.attachment?.bytes,
      );
      return Assignment.fromMap(response);
    } catch (error) {
      throw InstructorAssignmentsRepositoryException(error.toString());
    }
  }

  @override
  Future<AssignmentSubmission> gradeSubmission({
    required String assignmentId,
    required String submissionId,
    required double score,
  }) async {
    try {
      final response = await StudentApi.gradeAssignmentSubmission(
        assignmentId: assignmentId,
        submissionId: submissionId,
        score: score,
      );
      return AssignmentSubmission.fromMap(response);
    } catch (error) {
      throw InstructorAssignmentsRepositoryException(error.toString());
    }
  }
}
