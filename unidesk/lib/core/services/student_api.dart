import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentApi {
  static const String _baseUrl = 'http://localhost:8000/api';

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
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

  static Future<dynamic> _decode(http.Response response) async {
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
    String userId,
    String password,
  ) async {
    final res = await http.post(
      _uri('/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': userId,
        'userId': userId,
        'password': password,
      }),
    );

    final body = await _decode(res);
    if (body is Map<String, dynamic>) {
      final data = body['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(body['data'] as Map<String, dynamic>)
          : const <String, dynamic>{};
      final nestedUser = data['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['user'] as Map<String, dynamic>)
          : const <String, dynamic>{};
      final topUser = body['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(body['user'] as Map<String, dynamic>)
          : const <String, dynamic>{};
      final user = nestedUser.isNotEmpty ? nestedUser : topUser;
      final token = (body['token'] ??
              body['access_token'] ??
              data['token'] ??
              data['access_token'] ??
              '')
          .toString();
      final role =
          (body['role'] ?? data['role'] ?? user['role'])?.toString();
      final message = body['message']?.toString() ?? '';
      final explicitSuccess = body['success'];
      final inferredSuccess = res.statusCode >= 200 &&
          res.statusCode < 300 &&
          (token.isNotEmpty || message.toLowerCase().contains('success'));

      return {
        'success': explicitSuccess is bool ? explicitSuccess : inferredSuccess,
        'token': token,
        'role': role,
        'user': user,
        'message': message,
      };
    }

    return {
      'success': false,
      'message': 'Unexpected login response (${res.statusCode})',
    };
  }

  static Future<void> logout({String? token}) async {
    token ??= await _readToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await http.post(
      _uri('/logout'),
      headers: _headers(token: token),
      body: jsonEncode(const <String, dynamic>{}),
    );
  }

  static Future<List<Map<String, dynamic>>> getCourses({String? token}) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/student/courses'),
      headers: _headers(token: token),
    );

    final body = await _decode(res);
    if (body is List) {
      return body.map<Map<String, dynamic>>((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList();
    }

    throw Exception('Courses request failed (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> getAcademicProgress({
    String? token,
  }) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/student/academic-progress'),
      headers: _headers(token: token),
    );

    final body = await _decode(res);
    if (body is Map<String, dynamic>) {
      return body;
    }

    throw Exception('Academic progress request failed (${res.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> getSchedule({String? token}) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/student/schedule'),
      headers: _headers(token: token),
    );

    final body = await _decode(res);
    if (body is List) {
      return body.map<Map<String, dynamic>>((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList();
    }

    throw Exception('Schedule request failed (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> getProfile({String? token}) async {
    token ??= await _readToken();
    final res = await http.get(
      _uri('/profile'),
      headers: _headers(token: token),
    );

    final body = await _decode(res);
    if (body is Map<String, dynamic>) {
      return body;
    }

    throw Exception('Profile request failed (${res.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> getAds() async {
    final res = await http.get(_uri('/announcements'), headers: _headers());
    final body = await _decode(res);

    if (body is List) {
      return body.map<Map<String, dynamic>>((e) {
        return Map<String, dynamic>.from(e as Map);
      }).toList();
    }

    throw Exception('Announcements request failed (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> registerAttendance({
    required String token,
    required String courseId,
  }) async {
    final authToken = await _readToken();
    final res = await http.post(
      _uri('/attendance/register'),
      headers: _headers(token: authToken),
      body: jsonEncode({
        'token': token,
        'courseId': courseId,
      }),
    );

    final body = await _decode(res);
    if (body is Map<String, dynamic>) {
      return body;
    }

    return {
      'success': false,
      'message': 'Unexpected attendance response (${res.statusCode})',
    };
  }
}
