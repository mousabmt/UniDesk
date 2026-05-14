import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';

abstract class InstructorAssignmentsRepository {
  Future<List<Assignment>> getAssignments();

  Future<List<AssignmentSubmission>> getAssignmentSubmissions(String assignmentId);

  Future<Assignment> createAssignment(CreateAssignmentRequest request);

  Future<AssignmentSubmission> gradeSubmission({
    required String assignmentId,
    required String submissionId,
    required double score,
  });
}

class InstructorAssignmentsRepositoryImpl
    implements InstructorAssignmentsRepository {
  const InstructorAssignmentsRepositoryImpl(this._dataSource);

  final InstructorAssignmentsDataSource _dataSource;

  @override
  Future<List<Assignment>> getAssignments() {
    return _dataSource.getAssignments();
  }

  @override
  Future<List<AssignmentSubmission>> getAssignmentSubmissions(
    String assignmentId,
  ) {
    return _dataSource.getAssignmentSubmissions(assignmentId);
  }

  @override
  Future<Assignment> createAssignment(CreateAssignmentRequest request) {
    return _dataSource.createAssignment(request);
  }

  @override
  Future<AssignmentSubmission> gradeSubmission({
    required String assignmentId,
    required String submissionId,
    required double score,
  }) {
    return _dataSource.gradeSubmission(
      assignmentId: assignmentId,
      submissionId: submissionId,
      score: score,
    );
  }
}

class InstructorAssignmentsRepositoryException implements Exception {
  const InstructorAssignmentsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
