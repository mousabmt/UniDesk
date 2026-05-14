import 'dart:typed_data';

import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/entities/student/assignments/data/student_assignments_data_source.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_assignment.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_submission.dart';

class ApiStudentAssignmentsDataSource implements StudentAssignmentsDataSource {
  const ApiStudentAssignmentsDataSource();

  @override
  Future<List<StudentAssignment>> getAssignments() async {
    try {
      final response = await StudentApi.getStudentAssignments();
      return response.map(StudentAssignment.fromMap).toList();
    } catch (error) {
      throw StudentAssignmentsDataSourceException(error.toString());
    }
  }

  @override
  Future<StudentAssignment> getAssignmentDetail(String assignmentId) async {
    try {
      final response = await StudentApi.getStudentAssignmentDetail(
        assignmentId: assignmentId,
      );
      return StudentAssignment.fromMap(response);
    } catch (error) {
      throw StudentAssignmentsDataSourceException(error.toString());
    }
  }

  @override
  Future<StudentSubmission> submitAssignment({
    required String assignmentId,
    required String fileName,
    String? localPath,
    Uint8List? fileBytes,
  }) async {
    try {
      final response = await StudentApi.submitAssignment(
        assignmentId: assignmentId,
        fileName: fileName,
        localPath: localPath,
        fileBytes: fileBytes,
      );
      return StudentSubmission.fromMap(response);
    } catch (error) {
      throw StudentAssignmentsDataSourceException(error.toString());
    }
  }

  @override
  Future<List<StudentSubmission>> getSubmissions() async {
    try {
      final response = await StudentApi.getStudentSubmissions();
      return response.map(StudentSubmission.fromMap).toList();
    } catch (error) {
      throw StudentAssignmentsDataSourceException(error.toString());
    }
  }
}
