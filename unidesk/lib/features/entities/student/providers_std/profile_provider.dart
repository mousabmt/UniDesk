import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidesk/core/services/student_api.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIfNeeded({String? token}) async {
    if (_profile != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final resolvedToken = token ?? await StudentApi.readToken();

      if (resolvedToken != null && resolvedToken.isNotEmpty) {
        final rawProfile = await StudentApi.getProfile(token: resolvedToken);
        _profile = _normalizeProfile(rawProfile);
        await prefs.setString('user', jsonEncode(_profile));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _profile = null;
    await loadIfNeeded();
  }

  void clear() {
    _profile = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Map<String, dynamic> _normalizeProfile(Map<String, dynamic> rawProfile) {
    final profile = Map<String, dynamic>.from(rawProfile);
    final firstNameEn = profile['first_name_en']?.toString().trim();
    final lastNameEn = profile['last_name_en']?.toString().trim();
    final englishName = [
      if (firstNameEn != null && firstNameEn.isNotEmpty) firstNameEn,
      if (lastNameEn != null && lastNameEn.isNotEmpty) lastNameEn,
    ].join(' ');

    final fallbackName = profile['name']?.toString().trim();
    final displayName = englishName.isNotEmpty
        ? englishName
        : (fallbackName != null && fallbackName.isNotEmpty
              ? fallbackName
              : '-');

    final completedCredits =
        profile['credits'] ?? profile['total_credits_attempted'];
    final attemptedCredits =
        profile['total_credits_attempted'] ?? profile['totalHours'];
    final completedCourses = profile['completed_courses'];
    final currentCourses = profile['current_courses'];

    return {
      ...profile,
      'name': displayName,
      'id': (profile['student_number'] ?? profile['student_id'] ?? '-')
          .toString(),
      'student_number': (profile['student_number'] ?? '').toString(),
      'student_id': profile['student_id'],
      'credits': completedCredits,
      'creditsEarned': completedCredits,
      'totalHours': attemptedCredits,
      'totalCredits': attemptedCredits,
      'completedCourses': completedCourses,
      'currentCourses': currentCourses,
      'total_credits_attempted': attemptedCredits,
      'major': profile['major']?.toString() ?? '',
      'personal_email':
          profile['personal_email']?.toString() ??
          profile['email']?.toString() ??
          '',
      'identifiers': [
        profile['phone']?.toString(),
        profile['national_id']?.toString(),
      ].whereType<String>().where((value) => value.isNotEmpty).toList(),
    };
  }
}
