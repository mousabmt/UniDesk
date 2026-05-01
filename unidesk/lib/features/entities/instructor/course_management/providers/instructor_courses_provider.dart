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
  String? _selectedCourseId;
  InstructorCourseDetails? _currentCourseDetails;
  bool _isDetailsLoading = false;
  String? _detailsError;
  bool _isUploading = false;
  String? _uploadError;

  List<InstructorManagedCourse> get courses => _courses;
  bool get isCoursesLoading => _isCoursesLoading;
  String? get coursesError => _coursesError;
  String? get selectedCourseId => _selectedCourseId;
  InstructorManagedCourse? get selectedCourse {
    for (final course in _courses) {
      if (course.id == _selectedCourseId) {
        return course;
      }
    }
    return _courses.isEmpty ? null : _courses.first;
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
      if (preferredCourseId != null && preferredCourseId != _selectedCourseId) {
        await selectCourse(instructorId: instructorId, courseId: preferredCourseId);
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
        final fallbackId = preferredCourseId ?? _selectedCourseId ?? _courses.first.id;
        _selectedCourseId = _courses.any((course) => course.id == fallbackId)
            ? fallbackId
            : _courses.first.id;
      } else {
        _selectedCourseId = null;
      }
    } catch (e) {
      _courses = const [];
      _selectedCourseId = null;
      _coursesError = e.toString();
    } finally {
      _isCoursesLoading = false;
      notifyListeners();
    }

    if (_selectedCourseId != null) {
      await _loadCourseDetails(instructorId: instructorId);
    }
  }

  Future<void> selectCourse({
    required String instructorId,
    required String courseId,
  }) async {
    if (courseId == _selectedCourseId && _currentCourseDetails != null) {
      return;
    }
    _selectedCourseId = courseId;
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
      preferredCourseId: preferredCourseId ?? _selectedCourseId,
    );
  }

  Future<bool> uploadCourseFile({
    required String instructorId,
    required String fileName,
    required InstructorCourseFileCategory category,
    required String extensionLabel,
    String? localPath,
  }) async {
    final courseId = _selectedCourseId;
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
    final courseId = _selectedCourseId;
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
      );
    } catch (e) {
      _currentCourseDetails = null;
      _detailsError = e.toString();
    } finally {
      _isDetailsLoading = false;
      notifyListeners();
    }
  }
}
