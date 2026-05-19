import 'package:flutter/material.dart';
import 'package:unidesk/core/services/student_api.dart';

class CoursesProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? _courses;
  Map<String, dynamic>? _academicProgress;

  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>>? get courses => _courses;
  Map<String, dynamic>? get academicProgress => _academicProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded({String? token}) async {
    if (_courses != null && _academicProgress != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await StudentApi.getCourses(token: token);
      _academicProgress = await StudentApi.getAcademicProgress(token: token);
      final grades = List<Map<String, dynamic>>.from(
        _academicProgress?['grades'] ?? const [],
      );
      final gradesByCourseCode = <String, Map<String, dynamic>>{
        for (final grade in grades)
          grade['course_code']?.toString() ?? '': grade,
      };

      _courses = (_courses ?? const []).map((course) {
        final code = course['id']?.toString() ?? '';
        final grade = gradesByCourseCode[code];
        if (grade == null) {
          return course;
        }

        return {
          ...course,
          'grade':
              grade['final_score']?.toString() ??
              grade['grade_symbol']?.toString() ??
              course['grade'],
        };
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({String? token}) async {
    _courses = null;
    _academicProgress = null;
    await loadIfNeeded(token: token);
  }

  void clear() {
    _courses = null;
    _academicProgress = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
