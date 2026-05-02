import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_repository.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';

class ApiInstructorAssignmentsDataSource
    implements InstructorAssignmentsDataSource {
  const ApiInstructorAssignmentsDataSource();

  @override
  Future<List<Assignment>> getAssignments({required String courseId}) {
    throw const InstructorAssignmentsRepositoryException(
      'Instructor assignments API is not connected yet.',
    );
  }

  @override
  Future<List<AssignmentSubmission>> getAssignmentSubmissions({
    required String courseId,
    required String assignmentId,
  }) {
    throw const InstructorAssignmentsRepositoryException(
      'Instructor assignments API is not connected yet.',
    );
  }

  @override
  Future<Assignment> createAssignment(CreateAssignmentRequest request) {
    throw const InstructorAssignmentsRepositoryException(
      'Instructor assignments API is not connected yet.',
    );
  }
}
