import 'package:flutter/material.dart';
import 'package:unidesk/core/services/mockApi.dart';

class CoursesProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? _courses;
  Map<String, dynamic>? _academicProgress;

  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>>? get courses => _courses;
  Map<String, dynamic>? get academicProgress => _academicProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches only if data isn't already cached.
  Future<void> loadIfNeeded() async {
    if (_courses != null && _academicProgress != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await MockApi.getCourses();
      _academicProgress = await MockApi.getAcademicProgress();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _courses = null;
    _academicProgress = null;
    await loadIfNeeded();
  }
}
