import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentApi {
  static const String _baseUrl = 'http://127.0.0.1:8002/api';

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<Map<String, dynamic>>> getCourses({String? token}) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/student/courses'),
      headers: _headers(token: token),
    );

    if (res.statusCode != 200) {
      throw Exception('Courses request failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['courses'] as List?) ?? [];

    return list
        .map<Map<String, dynamic>>((e) {
          final map = e as Map<String, dynamic>;
          return {
            'id': map['id']?.toString() ?? '',
            'name': map['name']?.toString() ?? '',
            'instructor': map['instructor']?.toString() ?? '',
            'credits': map['credits'] ?? 0,
            'grade': map['grade']?.toString() ?? 'N/A',
            'absences': (map['absences'] ?? 0) is int
                ? map['absences']
                : int.tryParse(map['absences'].toString()) ?? 0,
          };
        })
        .toList();
  }

  static Future<Map<String, dynamic>> getAcademicProgress({String? token}) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/student/academic-progress'),
      headers: _headers(token: token),
    );

    if (res.statusCode != 200) {
      throw Exception('Academic progress request failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final completed = (body['completed_courses'] as List?) ?? [];

    // Ensure each semester has a courses array to satisfy the UI.
    final normalized = completed.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e as Map);
      map.putIfAbsent('courses', () => <Map<String, dynamic>>[]);
      return map;
    }).toList();

    return {'completed_courses': normalized};
  }

  static Future<List<Map<String, dynamic>>> getSchedule({String? token}) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/student/schedule'),
      headers: _headers(token: token),
    );

    if (res.statusCode != 200) {
      throw Exception('Schedule request failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['schedule'] as List?) ?? [];

    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final raw in list) {
      final item = raw as Map<String, dynamic>;
      final day = _normalizeDay(item['day_of_week']?.toString());
      grouped.putIfAbsent(day, () => []);

      final instructorName = _formatInstructor(
        item['instructor_first_name'],
        item['instructor_last_name'],
        item['instructor_email'],
      );

      grouped[day]!.add({
        'id': item['course_code']?.toString() ?? '',
        'name': item['course_name']?.toString() ?? '',
        'time':
            '${item['start_time'] ?? ''} - ${item['end_time'] ?? ''}'.trim(),
        'room': _formatRoom(item['building'], item['room_code']),
        'instructor': instructorName,
      });
    }

    return grouped.entries
        .map((e) => {
              'day': e.key,
              'courses': e.value,
            })
        .toList();
  }

  static String _normalizeDay(String? value) {
    if (value == null || value.isEmpty) return 'Unknown';
    final lower = value.toLowerCase();
    if (lower.contains('sun')) return 'Sunday';
    if (lower.contains('mon')) return 'Monday';
    if (lower.contains('tue')) return 'Tuesday';
    if (lower.contains('wed')) return 'Wednesday';
    if (lower.contains('thu')) return 'Thursday';
    if (lower.contains('fri')) return 'Friday';
    if (lower.contains('sat')) return 'Saturday';
    // Fallback: capitalize first letter
    return value[0].toUpperCase() + value.substring(1);
  }

  static String _formatRoom(dynamic building, dynamic room) {
    final b = (building ?? '').toString().trim();
    final r = (room ?? '').toString().trim();
    if (b.isEmpty && r.isEmpty) return '';
    if (b.isEmpty) return r;
    if (r.isEmpty) return b;
    return '$b / $r';
  }

  static String _formatInstructor(dynamic first, dynamic last, dynamic email) {
    final f = (first ?? '').toString().trim();
    final l = (last ?? '').toString().trim();
    final e = (email ?? '').toString().trim();
    final name = [f, l].where((p) => p.isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    return e.isNotEmpty ? e : 'N/A';
  }
}
