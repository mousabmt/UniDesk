import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/student/announcements/data/student_announcements_repository.dart';
import 'package:unidesk/features/entities/student/announcements/models/student_announcement.dart';

class StudentAnnouncementsProvider extends ChangeNotifier {
  StudentAnnouncementsProvider(this._repository);

  final StudentAnnouncementsRepository _repository;

  List<StudentAnnouncement> _announcements = const [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;

  List<StudentAnnouncement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAnnouncements => _announcements.isNotEmpty;

  Future<void> loadIfNeeded({String? token}) async {
    if (_hasLoadedOnce || _isLoading) {
      return;
    }
    await _loadAnnouncements();
  }

  Future<void> refresh({String? token}) async {
    await _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final announcements = await _repository.getAnnouncements();
      announcements.sort((first, second) {
        final firstDate =
            first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return secondDate.compareTo(firstDate);
      });
      _announcements = List<StudentAnnouncement>.unmodifiable(announcements);
      _hasLoadedOnce = true;
    } catch (error) {
      _error = error.toString();
      _announcements = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
