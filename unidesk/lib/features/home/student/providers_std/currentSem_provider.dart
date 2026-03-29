import 'package:flutter/material.dart';
import 'package:unidesk/core/services/student_api.dart';

class CurrentSemesterProvider extends ChangeNotifier {
  List<Map<String, dynamic>>? _schedule;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>>? get schdule => _schedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded() async {
    if (_schedule != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedule = await StudentApi.getSchedule();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
    Future<void> refresh() async {
  _schedule = null; // clear cache
  await loadIfNeeded();
}
}
