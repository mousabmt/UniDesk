import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

class InstructorCoursesProvider extends ChangeNotifier {
  InstructorCoursesProvider(this._repository);

  final InstructorCoursesRepository _repository;

  List<InstructorManagedCourse> _courses = const [];
  bool _isCoursesLoading = false;
  String? _coursesError;
  String? _selectedCourseGroupKey;
  String? _selectedSectionId;
  InstructorCourseDetails? _currentCourseDetails;
  bool _isDetailsLoading = false;
  String? _detailsError;
  bool _isUploading = false;
  String? _uploadError;

  List<InstructorManagedCourse> get courses => _courses;
  bool get isCoursesLoading => _isCoursesLoading;
  String? get coursesError => _coursesError;
  String? get selectedCourseId => selectedCourse?.id;
  String? get selectedCourseGroupKey => _selectedCourseGroupKey;
  String? get selectedCourseKey => selectedCourse?.selectionKey;
  String? get selectedSectionId => _selectedSectionId;
  String? get selectedSectionSelectionKey => selectedCourse?.selectionKey;

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
    for (final course in _courses) {
      final scopeId = _scopeIdFor(course);
      if (_courseIdentityKey(course) == _selectedCourseGroupKey &&
          (_selectedSectionId == null ||
              _selectedSectionId!.isEmpty ||
              scopeId == _selectedSectionId)) {
        return course;
      }
    }
    return null;
  }

  InstructorCourseDetails? get currentCourseDetails => _currentCourseDetails;
  bool get isDetailsLoading => _isDetailsLoading;
  String? get detailsError => _detailsError;
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

  List<InstructorCourseFile> get visibleFiles {
    return _currentCourseDetails?.files ?? const [];
  }

  Future<void> loadIfNeeded({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
  }) async {
    if (_courses.isNotEmpty) {
      final didApplySelection = _applyPreferredSelection(
        preferredCourseId: preferredCourseId,
        preferredSectionId: preferredSectionId,
      );
      if (didApplySelection) {
        await selectCourse(
          instructorId: instructorId,
          courseId: preferredCourseId ?? selectedCourseId ?? '',
          sectionId: preferredSectionId,
        );
      } else if (_currentCourseDetails == null) {
        await _loadCourseDetails(instructorId: instructorId);
      }
      return;
    }
    await loadCourses(
      instructorId: instructorId,
      preferredCourseId: preferredCourseId,
      preferredSectionId: preferredSectionId,
    );
  }

  Future<void> loadCourses({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
  }) async {
    if (_isCoursesLoading) {
      return;
    }
    _isCoursesLoading = true;
    _coursesError = null;
    notifyListeners();

    try {
      _courses = await _repository.getInstructorCourses(instructorId);
      if (_courses.isNotEmpty) {
        _selectPreferredCourseAndSection(
          preferredCourseId: preferredCourseId,
          preferredSectionId: preferredSectionId,
        );
      } else {
        _selectedCourseGroupKey = null;
        _selectedSectionId = null;
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
      await _loadCourseDetails(instructorId: instructorId);
    }
  }

  Future<void> selectCourse({
    required String instructorId,
    required String courseId,
    String? sectionId,
  }) async {
    final resolvedCourse =
        _resolveCourse(courseId) ??
        _resolveCourse(_resolveCourseId(courseId) ?? courseId);
    if (resolvedCourse == null) {
      return;
    }

    final nextCourseGroupKey = _courseIdentityKey(resolvedCourse);
    final nextSectionId = _resolveSectionForCourse(
      nextCourseGroupKey,
      preferredSectionId: sectionId,
    );
    if (nextCourseGroupKey == _selectedCourseGroupKey &&
        nextSectionId == _selectedSectionId &&
        _currentCourseDetails != null) {
      return;
    }

    _selectedCourseGroupKey = nextCourseGroupKey;
    _selectedSectionId = nextSectionId;
    _currentCourseDetails = null;
    _detailsError = null;
    notifyListeners();
    await _loadCourseDetails(instructorId: instructorId);
  }

  Future<void> selectSection({
    required String instructorId,
    required String sectionId,
  }) async {
    final courseGroupKey = _selectedCourseGroupKey;
    if (courseGroupKey == null || courseGroupKey.isEmpty) {
      return;
    }

    final nextSectionId = _resolveSectionForCourse(
      courseGroupKey,
      preferredSectionId: sectionId,
    );
    if (nextSectionId == null ||
        (nextSectionId == _selectedSectionId &&
            _currentCourseDetails != null)) {
      return;
    }

    _selectedSectionId = nextSectionId;
    _currentCourseDetails = null;
    _detailsError = null;
    notifyListeners();
    await _loadCourseDetails(instructorId: instructorId);
  }

  Future<void> refresh({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
  }) async {
    _currentCourseDetails = null;
    _uploadError = null;
    await loadCourses(
      instructorId: instructorId,
      preferredCourseId: preferredCourseId ?? selectedCourseId,
      preferredSectionId: preferredSectionId ?? _selectedSectionId,
    );
  }

  void clear() {
    _courses = const [];
    _isCoursesLoading = false;
    _coursesError = null;
    _selectedCourseGroupKey = null;
    _selectedSectionId = null;
    _currentCourseDetails = null;
    _isDetailsLoading = false;
    _detailsError = null;
    _isUploading = false;
    _uploadError = null;
    notifyListeners();
  }

  Future<bool> uploadCourseFile({
    required String instructorId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
    Uint8List? fileBytes,
  }) async {
    final courseId = selectedCourse?.id;
    if (courseId == null || _isUploading) {
      return false;
    }

    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      await _repository.uploadCourseFile(
        instructorId: instructorId,
        courseId: courseId,
        fileName: fileName,
        category: category,
        extensionLabel: extensionLabel,
        localPath: localPath,
        fileBytes: fileBytes,
      );
      await _loadCourseDetails(instructorId: instructorId);
      return true;
    } catch (e) {
      _uploadError = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCourseDetails({required String instructorId}) async {
    final course = selectedCourse;
    final courseId = course?.id;
    final sectionId = course?.sectionId.isNotEmpty == true
        ? course!.sectionId
        : course?.lectureId;
    if (courseId == null || _isDetailsLoading) {
      return;
    }

    _isDetailsLoading = true;
    _detailsError = null;
    notifyListeners();

    try {
      _currentCourseDetails = await _repository.getCourseDetails(
        instructorId: instructorId,
        courseId: courseId,
        sectionId: sectionId,
      );
    } catch (e) {
      _currentCourseDetails = null;
      _detailsError = e.toString();
    } finally {
      _isDetailsLoading = false;
      notifyListeners();
    }
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
    _currentCourseDetails = null;
    _detailsError = null;
    notifyListeners();
    return true;
  }

  String? _resolveCourseId(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final course in _courses) {
      if (course.matchesSelection(value) ||
          _normalized(course.id) == _normalized(value) ||
          _normalized(_courseIdentityKey(course)) == _normalized(value)) {
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
    final sections = _courses.where((course) {
      return _normalized(_courseIdentityKey(course)) ==
          normalizedCourseGroupKey;
    }).toList();
    if (sections.isEmpty) {
      return null;
    }

    final preferred = preferredSectionId;
    if (preferred != null && preferred.isNotEmpty) {
      for (final course in sections) {
        if (_scopeIdFor(course) == preferred ||
            course.selectionKey == preferred) {
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
