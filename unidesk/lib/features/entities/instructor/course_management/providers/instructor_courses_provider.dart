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
  String? _selectedCourseKey;
  InstructorCourseDetails? _currentCourseDetails;
  bool _isDetailsLoading = false;
  String? _detailsError;
  bool _isUploading = false;
  String? _uploadError;

  List<InstructorManagedCourse> get courses => _courses;
  bool get isCoursesLoading => _isCoursesLoading;
  String? get coursesError => _coursesError;
  String? get selectedCourseId => selectedCourse?.id;
  String? get selectedCourseKey => _selectedCourseKey;
  InstructorManagedCourse? get selectedCourse {
    for (final course in _courses) {
      if (course.matchesSelection(_selectedCourseKey)) {
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
  }) async {
    if (_courses.isNotEmpty) {
      final preferredSelectionKey = _resolveSelectionKey(preferredCourseId);
      if (preferredSelectionKey != null &&
          preferredSelectionKey != _selectedCourseKey) {
        await selectCourse(
          instructorId: instructorId,
          courseId: preferredSelectionKey,
        );
      } else if (_currentCourseDetails == null) {
        await _loadCourseDetails(instructorId: instructorId);
      }
      return;
    }
    await loadCourses(
      instructorId: instructorId,
      preferredCourseId: preferredCourseId,
    );
  }

  Future<void> loadCourses({
    required String instructorId,
    String? preferredCourseId,
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
        _selectedCourseKey =
            _resolveSelectionKey(preferredCourseId) ??
            _resolveSelectionKey(_selectedCourseKey) ??
            _courses.first.selectionKey;
      } else {
        _selectedCourseKey = null;
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
      await _loadCourseDetails(instructorId: instructorId);
    }
  }

  Future<void> selectCourse({
    required String instructorId,
    required String courseId,
  }) async {
    final nextSelectionKey = _resolveSelectionKey(courseId);
    if (nextSelectionKey == null) {
      return;
    }
    if (nextSelectionKey == _selectedCourseKey &&
        _currentCourseDetails != null) {
      return;
    }
    _selectedCourseKey = nextSelectionKey;
    _currentCourseDetails = null;
    _detailsError = null;
    notifyListeners();
    await _loadCourseDetails(instructorId: instructorId);
  }

  Future<void> refresh({
    required String instructorId,
    String? preferredCourseId,
  }) async {
    _currentCourseDetails = null;
    _uploadError = null;
    await loadCourses(
      instructorId: instructorId,
      preferredCourseId: preferredCourseId ?? _selectedCourseKey,
    );
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
