import 'package:flutter/material.dart';
import 'package:unidesk/core/services/student_api.dart';

class CoursesProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? _courses;
  Map<String, dynamic>? _academicProgress;

  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>>? get courses => _courses;
  Map<String,dynamic>? get academicProgress => _academicProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches only if data isn't already cached.
  Future<void> loadIfNeeded() async {
    if (_courses != null && _academicProgress != null) return; //  already cached, no need to fetch again

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await StudentApi.getCourses();
      _academicProgress = await StudentApi.getAcademicProgress();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> refresh() async {
  _courses = null; // clear cache
  _academicProgress=null;
  await loadIfNeeded();
}  
}
