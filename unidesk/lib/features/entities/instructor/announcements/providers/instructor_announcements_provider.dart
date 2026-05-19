import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/instructor/announcements/data/instructor_announcements_repository.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/create_announcement_request.dart';
import 'package:unidesk/features/entities/instructor/announcements/models/instructor_announcement.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';

class InstructorAnnouncementType {
  const InstructorAnnouncementType({
    required this.value,
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String value;
  final String labelKey;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

class InstructorAnnouncementsProvider extends ChangeNotifier {
  InstructorAnnouncementsProvider(
    this._announcementsRepository,
    this._coursesRepository,
  );

  static const String defaultAnnouncementType = 'general';

  static const List<InstructorAnnouncementType> announcementTypes = [
    InstructorAnnouncementType(
      value: 'general',
      labelKey: 'announcement_type_general',
      icon: Icons.campaign_outlined,
      color: Color(0xff0bb4b1),
      backgroundColor: Color(0xffe5f7f6),
    ),
    InstructorAnnouncementType(
      value: 'project_guidelines',
      labelKey: 'announcement_type_project_guidelines',
      icon: Icons.article_outlined,
      color: Color(0xff7c4dcc),
      backgroundColor: Color(0xfff0eafa),
    ),
    InstructorAnnouncementType(
      value: 'new_assignment',
      labelKey: 'announcement_type_new_assignment',
      icon: Icons.assignment_outlined,
      color: Color(0xff4a6fd4),
      backgroundColor: Color(0xffeaeeff),
    ),
    InstructorAnnouncementType(
      value: 'class_cancelled',
      labelKey: 'announcement_type_class_cancelled',
      icon: Icons.warning_amber_rounded,
      color: Color(0xffe05a47),
      backgroundColor: Color(0xffffece8),
    ),
    InstructorAnnouncementType(
      value: 'exam_schedule',
      labelKey: 'announcement_type_exam_schedule',
      icon: Icons.fact_check_outlined,
      color: Color(0xfff5a623),
      backgroundColor: Color(0xfffff4e5),
    ),
  ];

  final InstructorAnnouncementsRepository _announcementsRepository;
  final InstructorCoursesRepository _coursesRepository;

  List<InstructorManagedCourse> _courses = const [];
  bool _isCoursesLoading = false;
  String? _coursesError;
  String? _selectedCourseGroupKey;
  String? _selectedSectionId;

  List<InstructorAnnouncement> _allAnnouncements = const [];
  bool _isAnnouncementsLoading = false;
  String? _announcementsError;
  bool _hasLoadedAnnouncements = false;

  bool _isCreating = false;
  String? _createError;

  List<InstructorManagedCourse> get courses => _courses;
  bool get isCoursesLoading => _isCoursesLoading;
  String? get coursesError => _coursesError;
  String? get selectedCourseId => selectedCourse?.id;
  String? get selectedCourseGroupKey => _selectedCourseGroupKey;
  String? get selectedSectionId => _selectedSectionId;
  String? get selectedSectionSelectionKey => selectedCourse?.selectionKey;
  bool get isAnnouncementsLoading => _isAnnouncementsLoading;
  String? get announcementsError => _announcementsError;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

  List<InstructorManagedCourse> get availableCourses {
    final seen = <String>{};
    final unique = <InstructorManagedCourse>[];
    for (final course in _courses) {
      if (seen.add(_courseIdentityKey(course))) {
        unique.add(course);
      }
    }
    return unique;
  }

  List<InstructorManagedCourse> get availableSections {
    final courseGroupKey = _selectedCourseGroupKey;
    if (courseGroupKey == null || courseGroupKey.isEmpty) {
      return const [];
    }
    final seen = <String>{};
    final sections = <InstructorManagedCourse>[];
    for (final course in _courses) {
      if (_courseIdentityKey(course) == courseGroupKey &&
          seen.add(course.selectionKey)) {
        sections.add(course);
      }
    }
    return sections;
  }

  InstructorManagedCourse? get selectedCourse {
    final courseGroupKey = _selectedCourseGroupKey;
    final sectionId = _selectedSectionId;
    if (courseGroupKey == null || courseGroupKey.isEmpty) {
      return null;
    }
    for (final course in _courses) {
      final scopeId = _scopeIdFor(course);
      if (_courseIdentityKey(course) == courseGroupKey &&
          (sectionId == null || sectionId.isEmpty || scopeId == sectionId)) {
        return course;
      }
    }
    return null;
  }

  List<InstructorAnnouncement> get announcements {
    final currentCourse = selectedCourse;
    final sectionId = _selectedSectionId;
    if (currentCourse == null || sectionId == null) {
      return const [];
    }
    final visible = _allAnnouncements.where((announcement) {
      return _normalized(announcement.courseId) ==
              _normalized(currentCourse.id) &&
          _normalized(announcement.sectionId) == _normalized(sectionId);
    }).toList();
    visible.sort((first, second) {
      final firstDate =
          first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondDate =
          second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return secondDate.compareTo(firstDate);
    });
    return visible;
  }

  Future<void> loadIfNeeded({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
  }) async {
    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: preferredCourseId,
        preferredSectionId: preferredSectionId,
      );
      return;
    }

    if (_applyPreferredSelection(
      preferredCourseId: preferredCourseId,
      preferredSectionId: preferredSectionId,
    )) {
      await _loadAnnouncements();
      return;
    }

    if (!_hasLoadedAnnouncements && !_isAnnouncementsLoading) {
      await _loadAnnouncements();
    } else {
      notifyListeners();
    }
  }

  Future<void> loadCourses({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
  }) async {
    if (_isCoursesLoading) {
      return;
    }

    _isCoursesLoading = true;
    _coursesError = null;
    notifyListeners();

    try {
      _courses = await _coursesRepository.getInstructorCourses(instructorId);
      if (_courses.isEmpty) {
        _selectedCourseGroupKey = null;
        _selectedSectionId = null;
      } else {
        _selectPreferredCourseAndSection(
          preferredCourseId: preferredCourseId,
          preferredSectionId: preferredSectionId,
        );
      }
    } catch (error) {
      _courses = const [];
      _selectedCourseGroupKey = null;
      _selectedSectionId = null;
      _coursesError = error.toString();
    } finally {
      _isCoursesLoading = false;
      notifyListeners();
    }

    if (selectedCourse != null) {
      await _loadAnnouncements();
    }
  }

  Future<void> selectCourse({
    required String instructorId,
    required String courseId,
  }) async {
    final resolvedCourse =
        _resolveCourse(courseId) ??
        _resolveCourse(_resolveCourseId(courseId) ?? courseId);
    if (resolvedCourse == null) {
      return;
    }

    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: courseId,
      );
      return;
    }

    final nextSectionId = _resolveSectionForCourse(
      _courseIdentityKey(resolvedCourse),
    );
    final noChange =
        _courseIdentityKey(resolvedCourse) == _selectedCourseGroupKey &&
        nextSectionId == _selectedSectionId;
    if (noChange) {
      return;
    }

    _selectedCourseGroupKey = _courseIdentityKey(resolvedCourse);
    _selectedSectionId = nextSectionId;
    notifyListeners();
  }

  Future<void> selectSection({
    required String instructorId,
    required String sectionId,
  }) async {
    if (_selectedCourseGroupKey == null) {
      return;
    }
    final nextSectionId = _resolveSectionForCourse(
      _selectedCourseGroupKey!,
      preferredSectionId: sectionId,
    );
    if (nextSectionId == null || nextSectionId == _selectedSectionId) {
      return;
    }

    _selectedSectionId = nextSectionId;
    notifyListeners();
  }

  Future<void> refresh({
    required String instructorId,
    String? preferredCourseId,
    String? preferredSectionId,
  }) async {
    if (_courses.isEmpty) {
      await loadCourses(
        instructorId: instructorId,
        preferredCourseId: preferredCourseId,
        preferredSectionId: preferredSectionId,
      );
      return;
    }
    _applyPreferredSelection(
      preferredCourseId: preferredCourseId,
      preferredSectionId: preferredSectionId,
    );
    await _loadAnnouncements();
  }

  Future<bool> createAnnouncement(CreateAnnouncementRequest request) async {
    if (_isCreating) {
      return false;
    }

    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      await _announcementsRepository.createAnnouncement(request);
      await _loadAnnouncements();
      return true;
    } catch (error) {
      _createError = error.toString();
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  void clearCreateError() {
    if (_createError == null) {
      return;
    }
    _createError = null;
    notifyListeners();
  }

  InstructorAnnouncementType typeFor(String value) {
    return announcementTypes.firstWhere(
      (type) => type.value == value,
      orElse: () => announcementTypes.first,
    );
  }

  String? sectionLabelFor(InstructorManagedCourse course) {
    if (course.sectionLabel.trim().isNotEmpty) {
      return course.sectionLabel.trim();
    }
    if (course.sectionId.trim().isNotEmpty) {
      return 'Section ${course.sectionId.trim()}';
    }
    if (course.lectureId.trim().isNotEmpty) {
      return 'Section ${course.lectureId.trim()}';
    }
    return null;
  }

  String courseSelectionValueFor(InstructorManagedCourse course) {
    return _courseIdentityKey(course);
  }

  Future<void> _loadAnnouncements() async {
    if (_isAnnouncementsLoading) {
      return;
    }

    _isAnnouncementsLoading = true;
    _announcementsError = null;
    notifyListeners();

    try {
      _allAnnouncements = await _announcementsRepository.getAnnouncements();
      _hasLoadedAnnouncements = true;
    } catch (error) {
      _allAnnouncements = const [];
      _announcementsError = error.toString();
    } finally {
      _isAnnouncementsLoading = false;
      notifyListeners();
    }
  }

  void _selectPreferredCourseAndSection({
    String? preferredCourseId,
    String? preferredSectionId,
  }) {
    final resolvedCourseId =
        _resolveCourseId(preferredCourseId) ??
        _resolveCourseId(selectedCourse?.id) ??
        _courses.first.id;
    final resolvedCourse = _resolveCourse(resolvedCourseId) ?? _courses.first;
    _selectedCourseGroupKey = _courseIdentityKey(resolvedCourse);
    _selectedSectionId = _resolveSectionForCourse(
      _selectedCourseGroupKey!,
      preferredSectionId: preferredSectionId ?? _selectedSectionId,
    );
  }

  bool _applyPreferredSelection({
    String? preferredCourseId,
    String? preferredSectionId,
  }) {
    final nextCourseId = _resolveCourseId(preferredCourseId);
    final nextCourse = _resolveCourse(nextCourseId ?? preferredCourseId);
    if (nextCourse == null) {
      return false;
    }
    final nextCourseGroupKey = _courseIdentityKey(nextCourse);
    final nextSectionId = _resolveSectionForCourse(
      nextCourseGroupKey,
      preferredSectionId: preferredSectionId,
    );
    if (nextCourseGroupKey == _selectedCourseGroupKey &&
        nextSectionId == _selectedSectionId) {
      return false;
    }
    _selectedCourseGroupKey = nextCourseGroupKey;
    _selectedSectionId = nextSectionId;
    notifyListeners();
    return true;
  }

  String? _resolveCourseId(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalizedValue = _normalized(value);
    for (final course in _courses) {
      if (course.matchesSelection(value) ||
          _normalized(course.id) == normalizedValue ||
          _normalized(_courseIdentityKey(course)) == normalizedValue) {
        return course.id;
      }
    }
    if (value.contains('::')) {
      final parts = value.split('::');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        return parts.first;
      }
    }
    return null;
  }

  InstructorManagedCourse? _resolveCourse(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalizedValue = _normalized(value);
    for (final course in _courses) {
      if (course.matchesSelection(value) ||
          _normalized(course.id) == normalizedValue ||
          _normalized(_courseIdentityKey(course)) == normalizedValue) {
        return course;
      }
    }
    return null;
  }

  String? _resolveSectionForCourse(
    String courseGroupKey, {
    String? preferredSectionId,
  }) {
    final normalizedCourseGroupKey = _normalized(courseGroupKey);
    final sections = _courses
        .where(
          (course) =>
              _normalized(_courseIdentityKey(course)) ==
              normalizedCourseGroupKey,
        )
        .toList();
    if (sections.isEmpty) {
      return null;
    }

    final preferred = preferredSectionId;
    if (preferred != null && preferred.isNotEmpty) {
      for (final course in sections) {
        if (_scopeIdFor(course) == preferred ||
            course.selectionKey == preferred) {
          return _scopeIdFor(course);
        }
      }
      if (preferred.contains('::')) {
        final parts = preferred.split('::');
        if (parts.length > 1) {
          return _resolveSectionForCourse(
            courseGroupKey,
            preferredSectionId: parts[1],
          );
        }
      }
    }

    return _scopeIdFor(sections.first);
  }

  String _scopeIdFor(InstructorManagedCourse course) {
    if (course.sectionId.isNotEmpty) {
      return course.sectionId;
    }
    if (course.lectureId.isNotEmpty) {
      return course.lectureId;
    }
    return course.id;
  }

  String _courseIdentityKey(InstructorManagedCourse course) {
    final code = _normalized(course.courseCode);
    final name = _normalized(course.name);
    final term = _normalized(course.term);
    final semesterId = _normalized(course.semesterId);
    final primary = code.isNotEmpty ? code : _normalized(course.id);
    return '$primary::$name::$semesterId::$term';
  }

  String _normalized(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }
}
