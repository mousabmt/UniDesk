import 'package:unidesk/features/entities/student/assignments/data/student_assignments_data_source.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_assignment.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_submission.dart';

abstract class StudentAssignmentsRepository {
  Future<List<StudentAssignment>> getAssignments();

  Future<StudentAssignment> getAssignmentDetail(String assignmentId);

  Future<StudentSubmission> submitAssignment({
    required String assignmentId,
    required String fileName,
    required String localPath,
  });

  Future<List<StudentSubmission>> getSubmissions();
}

class StudentAssignmentsRepositoryImpl implements StudentAssignmentsRepository {
  const StudentAssignmentsRepositoryImpl(this._dataSource);

  final StudentAssignmentsDataSource _dataSource;

  @override
  Future<List<StudentAssignment>> getAssignments() {
    return _dataSource.getAssignments();
  }

  @override
  Future<StudentAssignment> getAssignmentDetail(String assignmentId) {
    return _dataSource.getAssignmentDetail(assignmentId);
  }

  @override
  Future<StudentSubmission> submitAssignment({
    required String assignmentId,
    required String fileName,
    required String localPath,
  }) {
    return _dataSource.submitAssignment(
      assignmentId: assignmentId,
      fileName: fileName,
      localPath: localPath,
    );
  }

  @override
  Future<List<StudentSubmission>> getSubmissions() {
    return _dataSource.getSubmissions();
  }
}

class StudentAssignmentsRepositoryException implements Exception {
  const StudentAssignmentsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
