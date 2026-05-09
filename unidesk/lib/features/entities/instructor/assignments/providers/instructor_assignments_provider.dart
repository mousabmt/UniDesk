import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_repository.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/assignment_submission.dart';
import 'package:unidesk/features/entities/instructor/assignments/models/create_assignment_request.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

class InstructorAssignmentsProvider extends ChangeNotifier {
  InstructorAssignmentsProvider(
    this._assignmentsRepository,
    this._coursesRepository,
  );

  final InstructorAssignmentsRepository _assignmentsRepository;
  final InstructorCoursesRepository _coursesRepository;

  List<InstructorManagedCourse> _courses = const [];
  bool _isCoursesLoading = false;
  String? _coursesError;
  String? _selectedCourseKey;
  bool _isCourseLocked = false;

  List<Assignment> _assignments = const [];
  bool _isAssignmentsLoading = false;
  String? _assignmentsError;
  String? _selectedAssignmentId;

  List<AssignmentSubmission> _submissions = const [];
  bool _isSubmissionsLoading = false;
  String? _submissionsError;

  bool _isCreating = false;
  String? _createError;

  List<InstructorManagedCourse> get courses => _courses;
  bool get isCoursesLoading => _isCoursesLoading;
  String? get coursesError => _coursesError;
  String? get selectedCourseId => selectedCourse?.id;
  String? get selectedCourseKey => _selectedCourseKey;
  bool get isCourseLocked => _isCourseLocked;
  List<Assignment> get assignments => _assignments;
  bool get isAssignmentsLoading => _isAssignmentsLoading;
  String? get assignmentsError => _assignmentsError;
  String? get selectedAssignmentId => _selectedAssignmentId;
  List<AssignmentSubmission> get submissions => _submissions;
  bool get isSubmissionsLoading => _isSubmissionsLoading;
  String? get submissionsError => _submissionsError;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

  InstructorManagedCourse? get selectedCourse {
    for (final course in _courses) {
      if (course.matchesSelection(_selectedCourseKey)) {
        return course;
      }
    }
    return null;
  }

  Assignment? get selectedAssignment {
    for (final assignment in _assignments) {
      if (assignment.id == _selectedAssignmentId) {
        return assignment;
      }
    }
    return _assignments.isEmpty ? null : _assignments.first;
  }

  Future<void> loadIfNeeded({
    required String instructorId,
    String? preferredCourseId,
    bool lockCourseSelection = false,
  }) async {
    _isCourseLocked = lockCourseSelection;
    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: preferredCourseId,
        lockCourseSelection: lockCourseSelection,
      );
      return;
    }

    final preferredSelectionKey = _resolveSelectionKey(preferredCourseId);
    if (preferredSelectionKey != null &&
        preferredSelectionKey != _selectedCourseKey) {
      await selectCourse(
        instructorId: instructorId,
        courseId: preferredSelectionKey,
        lockCourseSelection: lockCourseSelection,
      );
      return;
    }

    if (_assignments.isEmpty && selectedCourse != null) {
      await _loadAssignments();
    } else if (_submissions.isEmpty && selectedAssignment != null) {
      await selectAssignment(selectedAssignment!.id);
    }
    notifyListeners();
  }

  Future<void> loadCourses({
    required String instructorId,
    String? preferredCourseId,
    bool lockCourseSelection = false,
  }) async {
    if (_isCoursesLoading) {
      return;
    }

    _isCourseLocked = lockCourseSelection;
    _isCoursesLoading = true;
    _coursesError = null;
    notifyListeners();

    try {
      _courses = await _coursesRepository.getInstructorCourses(instructorId);
      if (_courses.isEmpty) {
        _selectedCourseKey = null;
      } else {
        _selectedCourseKey =
            _resolveSelectionKey(preferredCourseId) ??
            _resolveSelectionKey(_selectedCourseKey) ??
            _courses.first.selectionKey;
      }
    } catch (e) {
      _courses = const [];
      _selectedCourseKey = null;
      _coursesError = e.toString();
    } finally {
      _isCoursesLoading = false;
      notifyListeners();
    }

    if (selectedCourse != null) {
      await _loadAssignments();
    }
  }

  Future<void> selectCourse({
    required String instructorId,
    required String courseId,
    bool? lockCourseSelection,
  }) async {
    if (lockCourseSelection != null) {
      _isCourseLocked = lockCourseSelection;
    }
    final nextSelectionKey = _resolveSelectionKey(courseId);
    if (nextSelectionKey == null) {
      return;
    }
    if (nextSelectionKey == _selectedCourseKey && _assignments.isNotEmpty) {
      return;
    }

    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: courseId,
        lockCourseSelection: _isCourseLocked,
      );
      return;
    }

    _selectedCourseKey = nextSelectionKey;
    _selectedAssignmentId = null;
    _assignments = const [];
    _submissions = const [];
    _assignmentsError = null;
    _submissionsError = null;
    notifyListeners();
    await _loadAssignments();
  }

  Future<void> refresh({
    required String instructorId,
    String? preferredCourseId,
    bool? lockCourseSelection,
  }) async {
    _assignments = const [];
    _submissions = const [];
    _selectedAssignmentId = null;
    await loadCourses(
      instructorId: instructorId,
      preferredCourseId: preferredCourseId ?? _selectedCourseKey,
      lockCourseSelection: lockCourseSelection ?? _isCourseLocked,
    );
  }

  Future<void> selectAssignment(String assignmentId) async {
    if (_isSubmissionsLoading) {
      return;
    }

    _selectedAssignmentId = assignmentId;
    _submissions = const [];
    _submissionsError = null;
    notifyListeners();
    await _loadSubmissions();
  }

  Future<bool> createAssignment(CreateAssignmentRequest request) async {
    if (_isCreating) {
      return false;
    }

    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final created = await _assignmentsRepository.createAssignment(request);
      if (created.courseId == selectedCourse?.id) {
        await _loadAssignments(preferredAssignmentId: created.id);
      }
      return true;
    } catch (e) {
      _createError = e.toString();
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> _loadAssignments({String? preferredAssignmentId}) async {
    final courseId = selectedCourse?.id;
    if (courseId == null || _isAssignmentsLoading) {
      return;
    }

    _isAssignmentsLoading = true;
    _assignmentsError = null;
    notifyListeners();

    try {
      _assignments = await _assignmentsRepository.getAssignments(
        courseId: courseId,
      );
      if (_assignments.isEmpty) {
        _selectedAssignmentId = null;
        _submissions = const [];
      } else {
        final nextAssignmentId =
            preferredAssignmentId ??
            _selectedAssignmentId ??
            _assignments.first.id;
        _selectedAssignmentId =
            _assignments.any((item) => item.id == nextAssignmentId)
            ? nextAssignmentId
            : _assignments.first.id;
      }
    } catch (e) {
      _assignments = const [];
      _selectedAssignmentId = null;
      _submissions = const [];
      _assignmentsError = e.toString();
    } finally {
      _isAssignmentsLoading = false;
      notifyListeners();
    }

    if (_selectedAssignmentId != null) {
      await _loadSubmissions();
    }
  }

  Future<void> _loadSubmissions() async {
    final courseId = selectedCourse?.id;
    final assignmentId = _selectedAssignmentId;
    if (courseId == null || assignmentId == null || _isSubmissionsLoading) {
      return;
    }

    _isSubmissionsLoading = true;
    _submissionsError = null;
    notifyListeners();

    try {
      _submissions = await _assignmentsRepository.getAssignmentSubmissions(
        courseId: courseId,
        assignmentId: assignmentId,
      );
    } catch (e) {
      _submissions = const [];
      _submissionsError = e.toString();
    } finally {
      _isSubmissionsLoading = false;
      notifyListeners();
    }
  }

  String? _resolveSelectionKey(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final course in _courses) {
      if (course.matchesSelection(value)) {
        return course.selectionKey;
      }
    }
    return null;
  }
}
