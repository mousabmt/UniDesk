import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/student/assignments/data/student_assignments_repository.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_assignment.dart';
import 'package:unidesk/features/entities/student/assignments/models/student_submission.dart';

class StudentAssignmentsProvider extends ChangeNotifier {
  StudentAssignmentsProvider(this._repository);

  final StudentAssignmentsRepository _repository;

  List<StudentAssignment> _assignments = const [];
  bool _isLoadingAssignments = false;
  String? _assignmentsError;

  StudentAssignment? _selectedAssignment;
  bool _isLoadingAssignmentDetail = false;
  String? _assignmentDetailError;

  List<StudentSubmission> _submissions = const [];
  bool _isLoadingSubmissions = false;
  String? _submissionsError;

  bool _isSubmitting = false;
  String? _submitError;
  String? _submitSuccess;

  // Getters for assignments
  List<StudentAssignment> get assignments => _assignments;
  bool get isLoadingAssignments => _isLoadingAssignments;
  String? get assignmentsError => _assignmentsError;

  // Getters for assignment detail
  StudentAssignment? get selectedAssignment => _selectedAssignment;
  bool get isLoadingAssignmentDetail => _isLoadingAssignmentDetail;
  String? get assignmentDetailError => _assignmentDetailError;

  // Getters for submissions
  List<StudentSubmission> get submissions => _submissions;
  bool get isLoadingSubmissions => _isLoadingSubmissions;
  String? get submissionsError => _submissionsError;

  // Getters for submit state
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  String? get submitSuccess => _submitSuccess;

  Future<void> loadAssignments() async {
    if (_isLoadingAssignments) return;

    _isLoadingAssignments = true;
    _assignmentsError = null;
    notifyListeners();

    try {
      _assignments = await _repository.getAssignments();
      _assignmentsError = null;
    } catch (e) {
      _assignmentsError = e.toString();
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  Future<void> loadAssignmentDetail(String assignmentId) async {
    _isLoadingAssignmentDetail = true;
    _assignmentDetailError = null;
    _selectedAssignment = null;
    notifyListeners();

    try {
      _selectedAssignment = await _repository.getAssignmentDetail(assignmentId);
      _assignmentDetailError = null;
    } catch (e) {
      _assignmentDetailError = e.toString();
    } finally {
      _isLoadingAssignmentDetail = false;
      notifyListeners();
    }
  }

  Future<bool> submitAssignment({
    required String assignmentId,
    required String fileName,
    String? localPath,
    Uint8List? fileBytes,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    _submitSuccess = null;
    notifyListeners();

    try {
      await _repository.submitAssignment(
        assignmentId: assignmentId,
        fileName: fileName,
        localPath: localPath,
        fileBytes: fileBytes,
      );

      _submitSuccess = 'Assignment submitted successfully!';

      // Refresh the selected assignment to get updated submission info
      await loadAssignmentDetail(assignmentId);

      return true;
    } catch (e) {
      _submitError = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadSubmissions() async {
    if (_isLoadingSubmissions) return;

    _isLoadingSubmissions = true;
    _submissionsError = null;
    notifyListeners();

    try {
      _submissions = await _repository.getSubmissions();
      _submissionsError = null;
    } catch (e) {
      _submissionsError = e.toString();
    } finally {
      _isLoadingSubmissions = false;
      notifyListeners();
    }
  }

  void clearSubmitMessage() {
    _submitError = null;
    _submitSuccess = null;
    notifyListeners();
  }

  void clearErrors() {
    _assignmentsError = null;
    _assignmentDetailError = null;
    _submissionsError = null;
    _submitError = null;
    notifyListeners();
  }

  void clear() {
    _assignments = const [];
    _isLoadingAssignments = false;
    _assignmentsError = null;
    _selectedAssignment = null;
    _isLoadingAssignmentDetail = false;
    _assignmentDetailError = null;
    _submissions = const [];
    _isLoadingSubmissions = false;
    _submissionsError = null;
    _isSubmitting = false;
    _submitError = null;
    _submitSuccess = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clearErrors();
    super.dispose();
  }
}
