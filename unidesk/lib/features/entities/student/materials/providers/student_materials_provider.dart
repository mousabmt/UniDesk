import 'package:flutter/material.dart';
import 'package:unidesk/features/entities/student/materials/models/student_material_course_option.dart';
import 'package:unidesk/features/entities/student/materials/data/student_materials_repository.dart';
import 'package:unidesk/features/entities/student/materials/models/student_course_material.dart';

class StudentMaterialsProvider extends ChangeNotifier {
  StudentMaterialsProvider(this._repository);

  final StudentMaterialsRepository _repository;

  List<StudentCourseMaterial> _materials = const [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCourseSelectionValue;

  List<StudentCourseMaterial> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCourseSelectionValue => _selectedCourseSelectionValue;

  Future<void> loadIfNeeded({
    required List<StudentMaterialCourseOption> courseOptions,
  }) async {
    _cacheResolvedOptions(courseOptions);
    _syncSelection(courseOptions);
    if (_selectedCourseSelectionValue == null ||
        _materials.isNotEmpty ||
        _isLoading) {
      notifyListeners();
      return;
    }
    await _loadMaterialsForSelectedCourse();
  }

  Future<void> selectCourse({
    required String? selectionValue,
    required List<StudentMaterialCourseOption> courseOptions,
  }) async {
    _cacheResolvedOptions(courseOptions);
    _syncSelection(courseOptions, preferredSelectionValue: selectionValue);
    _materials = const [];
    _error = null;
    notifyListeners();

    if (_selectedCourseSelectionValue == null) {
      return;
    }

    await _loadMaterialsForSelectedCourse();
  }

  Future<void> refresh({
    required List<StudentMaterialCourseOption> courseOptions,
  }) async {
    _cacheResolvedOptions(courseOptions);
    _syncSelection(courseOptions);
    if (_selectedCourseSelectionValue == null) {
      _materials = const [];
      _error = null;
      notifyListeners();
      return;
    }
    await _loadMaterialsForSelectedCourse();
  }

  void _syncSelection(
    List<StudentMaterialCourseOption> courseOptions, {
    String? preferredSelectionValue,
  }) {
    if (courseOptions.isEmpty) {
      _selectedCourseSelectionValue = null;
      return;
    }

    if (preferredSelectionValue != null) {
      for (final option in courseOptions) {
        if (option.selectionValue == preferredSelectionValue) {
          _selectedCourseSelectionValue = option.selectionValue;
          return;
        }
      }
    }

    if (_selectedCourseSelectionValue != null) {
      for (final option in courseOptions) {
        if (option.selectionValue == _selectedCourseSelectionValue) {
          return;
        }
      }
    }

    _selectedCourseSelectionValue = courseOptions.first.selectionValue;
  }

  Future<void> _loadMaterialsForSelectedCourse() async {
    final selectionValue = _selectedCourseSelectionValue;
    if (selectionValue == null || _isLoading) {
      return;
    }

    final courseOption = _lastResolvedOptions.firstWhere(
      (option) => option.selectionValue == selectionValue,
      orElse: () => const StudentMaterialCourseOption(
        selectionValue: '',
        materialsCourseId: '',
        displayLabel: '',
      ),
    );
    if (courseOption.materialsCourseId.isEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _materials = await _repository.getMaterialsByCourse(
        courseOption.materialsCourseId,
      );
      _error = null;
    } catch (error) {
      _materials = const [];
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StudentMaterialCourseOption> _lastResolvedOptions = const [];

  void _cacheResolvedOptions(List<StudentMaterialCourseOption> courseOptions) {
    _lastResolvedOptions = List<StudentMaterialCourseOption>.unmodifiable(
      courseOptions,
    );
  }
}
