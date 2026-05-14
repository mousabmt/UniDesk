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
  String? _selectedCourseGroupKey;
  String? _selectedSectionId;
  bool _isCourseLocked = false;

  List<Assignment> _allAssignments = const [];
  bool _isAssignmentsLoading = false;
  String? _assignmentsError;
  String? _selectedAssignmentId;

  List<AssignmentSubmission> _submissions = const [];
  bool _isSubmissionsLoading = false;
  String? _submissionsError;
  bool _isGrading = false;
  String? _gradingSubmissionId;
  String? _gradeError;

  bool _isCreating = false;
  String? _createError;

  List<InstructorManagedCourse> get courses => _courses;
  bool get isCoursesLoading => _isCoursesLoading;
  String? get coursesError => _coursesError;
  String? get selectedCourseId => selectedCourse?.id;
  String? get selectedCourseGroupKey => _selectedCourseGroupKey;
  String? get selectedSectionId => _selectedSectionId;
  String? get selectedSectionSelectionKey => selectedCourse?.selectionKey;
  bool get isCourseLocked => _isCourseLocked;
  bool get isAssignmentsLoading => _isAssignmentsLoading;
  String? get assignmentsError => _assignmentsError;
  String? get selectedAssignmentId => _selectedAssignmentId;
  List<AssignmentSubmission> get submissions => _submissions;
  bool get isSubmissionsLoading => _isSubmissionsLoading;
  String? get submissionsError => _submissionsError;
  bool get isGrading => _isGrading;
  String? get gradingSubmissionId => _gradingSubmissionId;
  String? get gradeError => _gradeError;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

  List<InstructorManagedCourse> get availableCourses {
    final seen = <String>{};
    final unique = <InstructorManagedCourse>[];
    for (final course in _courses) {
      if (seen.add(_courseIdentityKey(course))) {
        unique.add(course);
      }
    }
    return unique;
  }

  List<InstructorManagedCourse> get availableSections {
    final courseGroupKey = _selectedCourseGroupKey;
    if (courseGroupKey == null || courseGroupKey.isEmpty) {
      return const [];
    }
    final seen = <String>{};
    final sections = <InstructorManagedCourse>[];
    for (final course in _courses) {
      if (_courseIdentityKey(course) == courseGroupKey &&
          seen.add(course.selectionKey)) {
        sections.add(course);
      }
    }
    return sections;
  }

  InstructorManagedCourse? get selectedCourse {
    final courseGroupKey = _selectedCourseGroupKey;
    final sectionId = _selectedSectionId;
    if (courseGroupKey == null || courseGroupKey.isEmpty) {
      return null;
    }
    for (final course in _courses) {
      final scopeId = _scopeIdFor(course);
      if (_courseIdentityKey(course) == courseGroupKey &&
          (sectionId == null || sectionId.isEmpty || scopeId == sectionId)) {
        return course;
      }
    }
    return null;
  }

  List<Assignment> get assignments {
    final currentCourse = selectedCourse;
    final sectionId = _selectedSectionId;
    if (currentCourse == null || sectionId == null) {
      return const [];
    }
    return _allAssignments.where((assignment) {
      return _normalized(assignment.courseId) == _normalized(currentCourse.id) &&
          _normalized(assignment.sectionId) == _normalized(sectionId);
    }).toList();
  }

  Assignment? get selectedAssignment {
    for (final assignment in assignments) {
      if (assignment.id == _selectedAssignmentId) {
        return assignment;
      }
    }
    final visibleAssignments = assignments;
    return visibleAssignments.isEmpty ? null : visibleAssignments.first;
  }

  Future<void> loadIfNeeded({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
    bool lockCourseSelection = false,
  }) async {
    _isCourseLocked = lockCourseSelection;
    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: preferredCourseId,
        preferredSectionId: preferredSectionId,
        lockCourseSelection: lockCourseSelection,
      );
      return;
    }

    if (_applyPreferredSelection(
      preferredCourseId: preferredCourseId,
      preferredSectionId: preferredSectionId,
    )) {
      await _loadAssignments();
      return;
    }

    if (_allAssignments.isEmpty && selectedCourse != null) {
      await _loadAssignments();
    } else if (_submissions.isEmpty && selectedAssignment != null) {
      await selectAssignment(selectedAssignment!.id);
    }
    notifyListeners();
  }

  Future<void> loadCourses({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
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
        _selectedCourseGroupKey = null;
        _selectedSectionId = null;
      } else {
        _selectPreferredCourseAndSection(
          preferredCourseId: preferredCourseId,
          preferredSectionId: preferredSectionId,
        );
      }
    } catch (e) {
      _courses = const [];
      _selectedCourseGroupKey = null;
      _selectedSectionId = null;
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
    String? sectionId,
    bool? lockCourseSelection,
  }) async {
    if (lockCourseSelection != null) {
      _isCourseLocked = lockCourseSelection;
    }
    final resolvedCourse =
        _resolveCourse(courseId) ??
        _resolveCourse(_resolveCourseId(courseId) ?? courseId);
    if (resolvedCourse == null) {
      return;
    }

    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: courseId,
        preferredSectionId: sectionId,
        lockCourseSelection: _isCourseLocked,
      );
      return;
    }

    final nextSectionId = _resolveSectionForCourse(
      _courseIdentityKey(resolvedCourse),
      preferredSectionId: sectionId,
    );
    final noChange =
        _courseIdentityKey(resolvedCourse) == _selectedCourseGroupKey &&
        nextSectionId == _selectedSectionId &&
        assignments.isNotEmpty;
    if (noChange) {
      return;
    }

    _selectedCourseGroupKey = _courseIdentityKey(resolvedCourse);
    _selectedSectionId = nextSectionId;
    _selectedAssignmentId = null;
    _submissions = const [];
    _submissionsError = null;
    notifyListeners();
    await _loadAssignments();
  }

  Future<void> selectSection({
    required String instructorId,
    required String sectionId,
  }) async {
    if (_selectedCourseGroupKey == null) {
      return;
    }
    final nextSectionId = _resolveSectionForCourse(
      _selectedCourseGroupKey!,
      preferredSectionId: sectionId,
    );
    if (nextSectionId == null || nextSectionId == _selectedSectionId) {
      return;
    }

    _selectedSectionId = nextSectionId;
    _selectedAssignmentId = null;
    _submissions = const [];
    _submissionsError = null;
    notifyListeners();
    await _loadAssignments();
  }

  Future<void> refresh({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
    bool? lockCourseSelection,
  }) async {
    _allAssignments = const [];
    _submissions = const [];
    _selectedAssignmentId = null;
    await loadCourses(
      instructorId: instructorId,
      preferredCourseId: preferredCourseId ?? _selectedCourseGroupKey,
      preferredSectionId: preferredSectionId ?? _selectedSectionId,
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
      if (selectedCourse != null &&
          created.courseId == selectedCourse!.id &&
          created.sectionId == _selectedSectionId) {
        await _loadAssignments(preferredAssignmentId: created.id);
      } else {
        await _loadAssignments();
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

  Future<bool> gradeSubmission({
    required String submissionId,
    required double score,
  }) async {
    final assignment = selectedAssignment;
    if (_isGrading || assignment == null) {
      return false;
    }
    if (score < 0 || score > assignment.maxScore) {
      _gradeError =
          'Score must be between 0 and ${assignment.maxScore} points.';
      notifyListeners();
      return false;
    }

    _isGrading = true;
    _gradingSubmissionId = submissionId;
    _gradeError = null;
    notifyListeners();

    try {
      final graded = await _assignmentsRepository.gradeSubmission(
        assignmentId: assignment.id,
        submissionId: submissionId,
        score: score,
      );
      _submissions = _submissions.map((submission) {
        if (submission.id != submissionId) {
          return submission;
        }
        return submission.copyWith(
          status: graded.status,
          score: graded.score,
          feedback: graded.feedback,
        );
      }).toList(growable: false);
      return true;
    } catch (e) {
      _gradeError = e.toString();
      return false;
    } finally {
      _isGrading = false;
      _gradingSubmissionId = null;
      notifyListeners();
    }
  }

  void clearGradeError() {
    if (_gradeError == null) {
      return;
    }
    _gradeError = null;
    notifyListeners();
  }

  String? sectionLabelFor(InstructorManagedCourse course) {
    if (course.sectionLabel.trim().isNotEmpty) {
      return course.sectionLabel.trim();
    }
    if (course.sectionId.trim().isNotEmpty) {
      return 'Section ${course.sectionId.trim()}';
    }
    if (course.lectureId.trim().isNotEmpty) {
      return 'Section ${course.lectureId.trim()}';
    }
    return null;
  }

  String courseSelectionValueFor(InstructorManagedCourse course) {
    return _courseIdentityKey(course);
  }

  Future<void> _loadAssignments({String? preferredAssignmentId}) async {
    if (selectedCourse == null || _isAssignmentsLoading) {
      return;
    }

    _isAssignmentsLoading = true;
    _assignmentsError = null;
    notifyListeners();

    try {
      _allAssignments = await _assignmentsRepository.getAssignments();
      final missingSectionIds = _allAssignments.any(
        (assignment) => assignment.sectionId.trim().isEmpty,
      );
      if (missingSectionIds) {
        throw const InstructorAssignmentsRepositoryException(
          'Assignments response is missing section identifiers.',
        );
      }

      final visibleAssignments = assignments;
      if (visibleAssignments.isEmpty) {
        _selectedAssignmentId = null;
        _submissions = const [];
      } else {
        final nextAssignmentId =
            preferredAssignmentId ?? _selectedAssignmentId ?? visibleAssignments.first.id;
        _selectedAssignmentId = visibleAssignments.any(
              (item) => item.id == nextAssignmentId,
            )
            ? nextAssignmentId
            : visibleAssignments.first.id;
      }
    } catch (e) {
      _allAssignments = const [];
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
    final assignmentId = _selectedAssignmentId;
    if (assignmentId == null || _isSubmissionsLoading) {
      return;
    }

    _isSubmissionsLoading = true;
    _submissionsError = null;
    notifyListeners();

    try {
      _submissions = await _assignmentsRepository.getAssignmentSubmissions(
        assignmentId,
      );
    } catch (e) {
      _submissions = const [];
      _submissionsError = e.toString();
    } finally {
      _isSubmissionsLoading = false;
      notifyListeners();
    }
  }

  void _selectPreferredCourseAndSection({
    String? preferredCourseId,
    String? preferredSectionId,
  }) {
    final resolvedCourseId =
        _resolveCourseId(preferredCourseId) ??
        _resolveCourseId(selectedCourse?.id) ??
        _courses.first.id;
    final resolvedCourse = _resolveCourse(resolvedCourseId) ?? _courses.first;
    _selectedCourseGroupKey = _courseIdentityKey(resolvedCourse);
    _selectedSectionId = _resolveSectionForCourse(
      _selectedCourseGroupKey!,
      preferredSectionId: preferredSectionId ?? _selectedSectionId,
    );
  }

  bool _applyPreferredSelection({
    String? preferredCourseId,
    String? preferredSectionId,
  }) {
    final nextCourseId = _resolveCourseId(preferredCourseId);
    final nextCourse = _resolveCourse(nextCourseId ?? preferredCourseId);
    if (nextCourse == null) {
      return false;
    }
    final nextCourseGroupKey = _courseIdentityKey(nextCourse);
    final nextSectionId = _resolveSectionForCourse(
      nextCourseGroupKey,
      preferredSectionId: preferredSectionId,
    );
    if (nextCourseGroupKey == _selectedCourseGroupKey &&
        nextSectionId == _selectedSectionId) {
      return false;
    }
    _selectedCourseGroupKey = nextCourseGroupKey;
    _selectedSectionId = nextSectionId;
    _selectedAssignmentId = null;
    _submissions = const [];
    _submissionsError = null;
    notifyListeners();
    return true;
  }

  String? _resolveCourseId(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalizedValue = _normalized(value);
    for (final course in _courses) {
      if (course.matchesSelection(value) ||
          _normalized(course.id) == normalizedValue ||
          _normalized(_courseIdentityKey(course)) == normalizedValue) {
        return course.id;
      }
    }
    if (value.contains('::')) {
      final parts = value.split('::');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        return parts.first;
      }
    }
    return null;
  }

  InstructorManagedCourse? _resolveCourse(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalizedValue = _normalized(value);
    for (final course in _courses) {
      if (course.matchesSelection(value) ||
          _normalized(course.id) == normalizedValue ||
          _normalized(_courseIdentityKey(course)) == normalizedValue) {
        return course;
      }
    }
    return null;
  }

  String? _resolveSectionForCourse(
    String courseGroupKey, {
    String? preferredSectionId,
  }) {
    final normalizedCourseGroupKey = _normalized(courseGroupKey);
    final sections = _courses
        .where(
          (course) => _normalized(_courseIdentityKey(course)) == normalizedCourseGroupKey,
        )
        .toList();
    if (sections.isEmpty) {
      return null;
    }

    final preferred = preferredSectionId;
    if (preferred != null && preferred.isNotEmpty) {
      for (final course in sections) {
        if (_scopeIdFor(course) == preferred || course.selectionKey == preferred) {
          return _scopeIdFor(course);
        }
      }
      if (preferred.contains('::')) {
        final parts = preferred.split('::');
        if (parts.length > 1) {
          return _resolveSectionForCourse(
            courseGroupKey,
            preferredSectionId: parts[1],
          );
        }
      }
    }

    return _scopeIdFor(sections.first);
  }

  String _scopeIdFor(InstructorManagedCourse course) {
    if (course.sectionId.isNotEmpty) {
      return course.sectionId;
    }
    if (course.lectureId.isNotEmpty) {
      return course.lectureId;
    }
    return course.id;
  }

  String _courseIdentityKey(InstructorManagedCourse course) {
    final code = _normalized(course.courseCode);
    final name = _normalized(course.name);
    final term = _normalized(course.term);
    final semesterId = _normalized(course.semesterId);
    final primary = code.isNotEmpty ? code : _normalized(course.id);
    return '$primary::$name::$semesterId::$term';
  }

  String _normalized(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }
}
