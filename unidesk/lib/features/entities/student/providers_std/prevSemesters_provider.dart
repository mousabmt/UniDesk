import 'package:flutter/material.dart';
import 'package:unidesk/core/services/student_api.dart';

class PrevsemestersProvider extends ChangeNotifier {
  Map<String, dynamic>? _completedCourses;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get completedCourses => _completedCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded({String? token}) async {
    if (_completedCourses != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _completedCourses = await StudentApi.getAcademicProgress(token: token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _completedCourses = null;
    await loadIfNeeded();
  }
}
