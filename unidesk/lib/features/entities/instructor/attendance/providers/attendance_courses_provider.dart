import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';

class AttendanceCoursesProvider extends ChangeNotifier {
  AttendanceCoursesProvider(this._repository);

  final AttendanceRepository _repository;

  List<AttendanceCourse> _courses = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCourseId;

  List<AttendanceCourse> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCourseId => _selectedCourseId;
  AttendanceCourse? get selectedCourse {
    for (final course in _courses) {
      if (course.id == _selectedCourseId) {
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
      if (_selectedCourseId != null &&
          !_courses.any((course) => course.id == _selectedCourseId)) {
        _selectedCourseId = null;
      }
    } on AttendanceRepositoryException catch (error) {
      _errorMessage = error.message;
      _courses = const [];
      _selectedCourseId = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCourse(String? courseId) {
    _selectedCourseId = courseId;
    notifyListeners();
  }
}
