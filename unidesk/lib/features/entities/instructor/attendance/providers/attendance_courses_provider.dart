import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';

class AttendanceCoursesProvider extends ChangeNotifier {
  AttendanceCoursesProvider(this._repository);

  final AttendanceRepository _repository;

  List<AttendanceCourse> _courses = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCourseKey;

  List<AttendanceCourse> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCourseId => selectedCourse?.id;
  String? get selectedCourseKey => _selectedCourseKey;
  AttendanceCourse? get selectedCourse {
    for (final course in _courses) {
      if (course.matchesSelection(_selectedCourseKey)) {
        return course;
      }
    }
    return null;
  }

  Future<void> loadIfNeeded({required String instructorId}) async {
    if (_courses.isNotEmpty || _isLoading) {
      return;
    }
    await load(instructorId: instructorId);
  }

  Future<void> load({required String instructorId}) async {
    if (instructorId.isEmpty) {
      _errorMessage = 'Missing instructor id';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courses = await _repository.getInstructorCourses(instructorId);
      _selectedCourseKey = _resolveSelectionKey(_selectedCourseKey);
    } on AttendanceRepositoryException catch (error) {
      _errorMessage = error.message;
      _courses = const [];
      _selectedCourseKey = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCourse(String? courseId) {
    _selectedCourseKey = _resolveSelectionKey(courseId);
    notifyListeners();
  }

  void clear() {
    _courses = const [];
    _isLoading = false;
    _errorMessage = null;
    _selectedCourseKey = null;
    notifyListeners();
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
