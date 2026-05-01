import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_course.dart';
import 'package:unidesk/features/entities/instructor/attendance/models/attendance_student.dart';

class AttendanceStudentsProvider extends ChangeNotifier {
  AttendanceStudentsProvider(this._repository);

  final AttendanceRepository _repository;

  List<AttendanceStudent> _students = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _loadedCourseId;

  List<AttendanceStudent> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get loadedCourseId => _loadedCourseId;
  int get totalStudents => _students.length;
  int get atRiskStudents => _students.where((student) => student.isAtRisk).length;
  int get regularStudents => totalStudents - atRiskStudents;
  int get presentStudents => _students.where((student) => student.isPresent).length;
  int get absentStudents => totalStudents - presentStudents;

  Future<void> loadForCourse(AttendanceCourse? course) async {
    if (course == null) {
      clear();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _loadedCourseId = course.id;
    notifyListeners();

    try {
      _students = await _repository.getCourseStudents(
        courseId: course.id,
        lectureId: course.lectureId,
      );
    } on AttendanceRepositoryException catch (error) {
      _students = const [];
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshForCourse(AttendanceCourse? course) async {
    await loadForCourse(course);
  }

  void clear() {
    _students = const [];
    _isLoading = false;
    _errorMessage = null;
    _loadedCourseId = null;
    notifyListeners();
  }
}
