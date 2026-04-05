import 'package:flutter/material.dart';
import 'package:unidesk/core/services/mockApi.dart';

class DeadlineModel {
  final String id;
  final String courseId;
  final String? courseName;
  final String title;
  final DateTime dueDate;
  final String type; // 'assignment' | 'exam' | 'quiz'
  final String status; // 'pending' | 'submitted' | 'late'

  const DeadlineModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.status,
  });

  bool get isSoon =>
      dueDate.difference(DateTime.now()).inDays <= 3 && status == 'pending';

  factory DeadlineModel.fromJson(Map<String, dynamic> json) => DeadlineModel(
        id: json['id'],
        courseId: json['course_id'],
        courseName: json['course_name'],
        title: json['title'],
        dueDate: DateTime.parse(json['due_date']).toLocal(),
        type: json['type'],
        status: json['status'],
      );
}

class LectureModel {
  final String id;
  final String courseId;
  final String? courseName;
  final String type; // 'lecture' | 'lab' | 'discussion'
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String instructor;

  const LectureModel({
    required this.id,
    required this.courseId,
    this.courseName,
    required this.type,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.instructor,
  });

  bool get isUpcoming =>
      startTime.isAfter(DateTime.now()) &&
      startTime.difference(DateTime.now()).inHours <= 24;

  factory LectureModel.fromJson(Map<String, dynamic> json) => LectureModel(
        id: json['id'],
        courseId: json['course_id'],
        courseName: json['course_name'],
        type: json['type'],
        room: json['room'],
        startTime: DateTime.parse(json['start_time']).toLocal(),
        endTime: DateTime.parse(json['end_time']).toLocal(),
        instructor: json['instructor'],
      );
}

class CalenderProvider extends ChangeNotifier {
  List<DeadlineModel> _deadlines = [];
  List<LectureModel> _lectures = [];
  DateTime? _currentDate;

  bool _isLoading = false;
  String? _error;

  List<DeadlineModel> get deadlines => _deadlines;
  List<LectureModel> get lectures => _lectures;
  DateTime? get currentDate => _currentDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded() async {
    if (_deadlines.isNotEmpty || _lectures.isNotEmpty) return;
    await loadForDate(DateTime.now());
  }

  Future<void> refresh() async {
    final target = _currentDate ?? DateTime.now();
    await _fetch(target);
  }

  Future<void> loadForDate(DateTime day) async {
    _currentDate = day;
    await _fetch(day);
  }

  Future<void> _fetch(DateTime day) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await MockApi.getCalenderEventsForDate(day);

      final assignments = (response['assignments'] as List?) ?? [];
      final lectures = (response['lectures'] as List?) ?? [];

      _deadlines = assignments
          .map((e) => DeadlineModel.fromJson(e as Map<String, dynamic>))
          .toList();

      _lectures = lectures
          .map((e) => LectureModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
