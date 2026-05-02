import 'package:unidesk/core/services/mockApi.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_repository.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';

class MockInstructorAssignmentsDataSource
    implements InstructorAssignmentsDataSource {
  const MockInstructorAssignmentsDataSource();

  @override
  Future<List<Assignment>> getAssignments({required String courseId}) async {
    final response = await MockApi.getCourseAssignments(courseId);
    if (response['success'] != true) {
      throw InstructorAssignmentsRepositoryException(
        response['message']?.toString() ?? 'Failed to load assignments',
      );
    }

    return List<Map<String, dynamic>>.from(
      response['data'] ?? const [],
    ).map(Assignment.fromMap).toList();
  }

  @override
  Future<List<AssignmentSubmission>> getAssignmentSubmissions({
    required String courseId,
    required String assignmentId,
  }) async {
    final response = await MockApi.getAssignmentSubmissions(
      courseId: courseId,
      assignmentId: assignmentId,
    );
    if (response['success'] != true) {
      throw InstructorAssignmentsRepositoryException(
        response['message']?.toString() ??
            'Failed to load assignment submissions',
      );
    }

    return List<Map<String, dynamic>>.from(
      response['data'] ?? const [],
    ).map(AssignmentSubmission.fromMap).toList();
  }

  @override
  Future<Assignment> createAssignment(CreateAssignmentRequest request) async {
    final response = await MockApi.createAssignment(
      courseId: request.courseId,
      title: request.title,
      description: request.description,
      dueDate: request.dueDate.toUtc().toIso8601String(),
      totalPoints: request.totalPoints,
      instructions: request.instructions,
      attachedFile: request.attachment?.toCreatePayload(),
    );
    if (response['success'] != true) {
      throw InstructorAssignmentsRepositoryException(
        response['message']?.toString() ?? 'Failed to create assignment',
      );
    }

    return Assignment.fromMap(
      Map<String, dynamic>.from(response['data'] ?? const {}),
    );
  }
}
