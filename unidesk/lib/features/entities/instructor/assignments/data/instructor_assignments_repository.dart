import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';

abstract class InstructorAssignmentsRepository {
  Future<List<Assignment>> getAssignments({required String courseId});

  Future<List<AssignmentSubmission>> getAssignmentSubmissions({
    required String courseId,
    required String assignmentId,
  });

  Future<Assignment> createAssignment(CreateAssignmentRequest request);
}

class InstructorAssignmentsRepositoryImpl
    implements InstructorAssignmentsRepository {
  const InstructorAssignmentsRepositoryImpl(this._dataSource);

  final InstructorAssignmentsDataSource _dataSource;

  @override
  Future<List<Assignment>> getAssignments({required String courseId}) {
    return _dataSource.getAssignments(courseId: courseId);
  }

  @override
  Future<List<AssignmentSubmission>> getAssignmentSubmissions({
    required String courseId,
    required String assignmentId,
  }) {
    return _dataSource.getAssignmentSubmissions(
      courseId: courseId,
      assignmentId: assignmentId,
    );
  }

  @override
  Future<Assignment> createAssignment(CreateAssignmentRequest request) {
    return _dataSource.createAssignment(request);
  }
}

class InstructorAssignmentsRepositoryException implements Exception {
  const InstructorAssignmentsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
