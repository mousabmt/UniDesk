import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentApi {
  static const String _baseUrl = String.fromEnvironment(
    'UNIDESK_API_BASE_URL',
    defaultValue: 'https://anguished-ankle-footprint.ngrok-free.dev/api',
  );

  static final Uri _baseUri = Uri.parse(_baseUrl);

  static Uri _uri(String path, {Map<String, dynamic>? queryParameters}) {
    return _baseUri.replace(
      path: '${_baseUri.path}$path',
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  static Map<String, String> _headers({
    String? token,
    String accept = 'application/json',
    String? contentType = 'application/json',
  }) {
    final headers = <String, String>{
      'Accept': accept,
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'FlutterApp',
    };
    if (contentType != null && contentType.isNotEmpty) {
      headers['Content-Type'] = contentType;
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> readToken() async => _readToken();

  static Future<dynamic> _decode(http.Response response) async {
    if (response.body.isEmpty) {
      return null;
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      return response.body;
    }

    return jsonDecode(response.body);
  }

  static String _messageFromBody(
    dynamic body, {
    String fallback = 'Request failed',
  }) {
    if (body is Map<String, dynamic>) {
      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      final error = body['error']?.toString();
      if (error != null && error.isNotEmpty) {
        return error;
      }
    }

    if (body is String && body.isNotEmpty) {
      return body;
    }

    return fallback;
  }

  static bool _isSuccessStatus(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static Future<Map<String, dynamic>> _normalizeLoginResponse(
    http.Response response,
  ) async {
    final body = await _decode(response);
    if (body is! Map<String, dynamic>) {
      return {
        'success': false,
        'message': 'Unexpected login response (${response.statusCode})',
      };
    }

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
    final token =
        (body['access_token'] ??
                body['token'] ??
                data['access_token'] ??
                data['token'] ??
                '')
            .toString();
    final role = (body['role'] ?? data['role'] ?? user['role'])?.toString();
    final explicitSuccess = body['success'];
    final inferredSuccess =
        _isSuccessStatus(response.statusCode) && token.isNotEmpty;
    final success = explicitSuccess is bool ? explicitSuccess : inferredSuccess;

    if (success && token.isNotEmpty) {
      await _saveToken(token);
    }

    return {
      'success': success,
      'token': token,
      'role': role,
      'user': user,
      'message': _messageFromBody(
        body,
        fallback: success ? 'Login successful' : 'Login failed',
      ),
    };
  }

  static Future<Map<String, dynamic>> login(
    String userId,
    String password, {
    String? roleHint,
  }) async {
    final preferredEndpoints = <String>[
      if (roleHint == 'student') '/login/student',
      if (roleHint == 'instructor') '/login/instructor',
      '/login',
      '/login/student',
      '/login/instructor',
    ];

    final attempted = <String>{};
    Map<String, dynamic>? lastFailure;

    for (final endpoint in preferredEndpoints) {
      if (!attempted.add(endpoint)) {
        continue;
      }

      final response = await http.post(
        _uri(endpoint),
        headers: _headers(),
        body: jsonEncode({'email': userId, 'password': password}),
      );

      final normalized = await _normalizeLoginResponse(response);
      if (normalized['success'] == true) {
        return normalized;
      }

      lastFailure = normalized;
      if (response.statusCode == 401 || response.statusCode == 422) {
        continue;
      }

      break;
    }

    return lastFailure ??
        {'success': false, 'message': 'Unable to login. Please try again.'};
  }

  static Future<void> logout({String? token}) async {
    token ??= await _readToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await http.post(
        _uri('/logout'),
        headers: _headers(token: token),
        body: jsonEncode(const <String, dynamic>{}),
      );
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }

  static Future<List<Map<String, dynamic>>> getCourses({String? token}) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/student/courses'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load courses'),
      );
    }

    final courses = body is Map<String, dynamic> ? body['courses'] : body;
    if (courses is! List) {
      throw Exception('Unexpected courses response (${response.statusCode})');
    }

    return courses.map<Map<String, dynamic>>((course) {
      final map = Map<String, dynamic>.from(course as Map);
      return {
        ...map,
        'id': map['course_code']?.toString() ?? map['id']?.toString() ?? '',
        'name': map['course_name']?.toString() ?? map['name']?.toString() ?? '',
        'credits': _toInt(map['credit_hours'] ?? map['credits']),
        'instructor': map['teaching_mode']?.toString() ?? '',
        'absences': _toInt(map['absences']),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getAcademicProgress({
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/student/academic-progress'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load academic progress'),
      );
    }

    final progress = Map<String, dynamic>.from(body);
    final grades = List<Map<String, dynamic>>.from(
      progress['grades'] ?? const [],
    );
    progress['completed_courses'] = _groupGradesBySemester(grades);
    return progress;
  }

  static Future<List<Map<String, dynamic>>> getSchedule({String? token}) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/student/schedule'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load schedule'),
      );
    }

    final schedule = body['schedule'];
    if (schedule is! List) {
      throw Exception('Unexpected schedule response (${response.statusCode})');
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in schedule) {
      final map = Map<String, dynamic>.from(item as Map);
      final dayLabel = _dayLabel(map['day_of_week']);
      grouped.putIfAbsent(dayLabel, () => <Map<String, dynamic>>[]).add({
        ...map,
        'id': map['course_code']?.toString() ?? '',
        'name': map['course_name']?.toString() ?? '',
        'time': _formatTimeRange(map['start_time'], map['end_time']),
        'room': _joinNonEmpty([
          map['building']?.toString(),
          map['room_code']?.toString(),
        ], separator: ' / '),
        'instructor': _joinNonEmpty([
          map['section_number'] != null
              ? 'Section ${map['section_number']}'
              : null,
          map['teaching_mode']?.toString(),
        ]),
      });
    }

    final orderedDays = <String>[
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return orderedDays
        .where(grouped.containsKey)
        .map((day) => {'day': day, 'courses': grouped[day]})
        .toList();
  }

  static Future<Map<String, dynamic>> getProfile({String? token}) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/profile'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load profile'),
      );
    }

    final user = body['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(body['user'] as Map<String, dynamic>)
        : Map<String, dynamic>.from(body);
    final role = body['role']?.toString() ?? user['role']?.toString();

    return {
      ...user,
      if (role != null && role.isNotEmpty) 'role': role,
      'user': user,
    };
  }

  static Future<List<Map<String, dynamic>>> getAds() async {
    final response = await http.get(
      _uri('/announcements'),
      headers: _headers(contentType: null),
    );
    final body = await _decode(response);

    if (!_isSuccessStatus(response.statusCode) || body is! List) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load announcements'),
      );
    }

    return body.map<Map<String, dynamic>>((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return {
        ...map,
        'imageUrl': _resolveAnnouncementImageUrl(map['image_url']?.toString()),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> registerAttendance({
    required String token,
    required String courseId,
  }) async {
    final authToken = await _readToken();
    final response = await http.post(
      _uri('/attendance/register'),
      headers: _headers(token: authToken),
      body: jsonEncode({
        'token': token,
        'course_id': courseId,
        'courseId': courseId,
      }),
    );

    final body = await _decode(response);
    if (body is Map<String, dynamic>) {
      return body;
    }

    return {
      'success': false,
      'message': 'Unexpected attendance response (${response.statusCode})',
    };
  }

  static Future<List<Map<String, dynamic>>> getInstructorCourses({
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/instructor/courses'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load instructor courses'),
      );
    }

    final courses = _extractInstructorCourses(body);
    if (courses == null) {
      throw Exception(
        'Unexpected instructor courses response (${response.statusCode})',
      );
    }

    return courses.map<Map<String, dynamic>>((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final sectionId =
          map['section_id']?.toString() ?? map['sectionId']?.toString() ?? '';
      final sectionNumber =
          map['section_number']?.toString() ??
          map['sectionLabel']?.toString() ??
          '';
      return {
        ...map,
        'id': map['course_id']?.toString() ?? map['id']?.toString() ?? '',
        'courseCode':
            map['course_code']?.toString() ??
            map['courseCode']?.toString() ??
            '',
        'name': map['course_name']?.toString() ?? map['name']?.toString() ?? '',
        'credits': _toInt(map['credit_hours'] ?? map['credits']),
        'studentsEnrolled': _toInt(
          map['students_enrolled'] ?? map['studentsEnrolled'],
        ),
        'lectureId': sectionId.isNotEmpty ? sectionId : sectionNumber,
        'sectionId': sectionId,
        'sectionLabel': sectionNumber,
        'teachingMode':
            map['teaching_mode']?.toString() ??
            map['teachingMode']?.toString() ??
            '',
        'term':
            map['semester_name']?.toString() ?? map['term']?.toString() ?? '',
        'semesterId':
            map['semester_id']?.toString() ??
            map['semesterId']?.toString() ??
            '',
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getSectionStudents({
    required String sectionId,
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/instructor/sections/$sectionId/students'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load course students'),
      );
    }

    final students = body['students'];
    if (students is! List) {
      throw Exception('Unexpected students response (${response.statusCode})');
    }

    return students.map<Map<String, dynamic>>((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return {
        ...map,
        'id': map['student_id']?.toString() ?? map['user_id']?.toString() ?? '',
        'userId': map['user_id']?.toString() ?? '',
        'name': map['name']?.toString() ?? '',
        'email': map['email']?.toString() ?? '',
        'status': map['student_status']?.toString() ?? 'enrolled',
        'absences': 0,
        'isPresent': false,
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getCourseFiles({
    required String courseId,
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/courses/$courseId/files'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) || body is! List) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load course files'),
      );
    }

    return body.map<Map<String, dynamic>>((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return _normalizeCourseFile(map);
    }).toList();
  }

  static Future<Map<String, dynamic>> uploadCourseFile({
    required String courseId,
    required String fileName,
    required int categoryId,
    String? localPath,
    Uint8List? fileBytes,
    String? token,
  }) async {
    token ??= await _readToken();
    final request = http.MultipartRequest(
      'POST',
      _uri('/courses/$courseId/files'),
    );
    request.headers.addAll(_headers(token: token, contentType: null));
    request.fields['category_id'] = categoryId.toString();
    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    } else if (localPath != null && localPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          localPath,
          filename: fileName,
        ),
      );
    } else {
      throw Exception('No file data was provided for upload.');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = await _decode(response);

    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to upload file'),
      );
    }

    final data = body['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(body['data'] as Map<String, dynamic>)
        : const <String, dynamic>{};
    if (data.isEmpty) {
      throw Exception('Unexpected upload response (${response.statusCode})');
    }

    return _normalizeCourseFile({
      ...data,
      'file_name': data['file_name'] ?? fileName,
      'localPath': localPath,
    });
  }

  static Future<List<Map<String, dynamic>>> getInstructorAssignments({
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/assignments'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load assignments'),
      );
    }

    final assignments = body is Map<String, dynamic>
        ? body['data'] ?? body['assignments']
        : body;
    if (assignments is! List) {
      throw Exception(
        'Unexpected assignments response (${response.statusCode})',
      );
    }

    return assignments.map<Map<String, dynamic>>((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  static Future<Map<String, dynamic>> createInstructorAssignment({
    required Map<String, dynamic> fields,
    String? fileName,
    String? localPath,
    Uint8List? fileBytes,
    String? token,
  }) async {
    token ??= await _readToken();
    final request = http.MultipartRequest('POST', _uri('/assignments'));
    request.headers.addAll(_headers(token: token, contentType: null));
    request.fields.addAll(
      fields.map((key, value) => MapEntry(key, value.toString())),
    );
    if (fileBytes != null && fileName != null && fileName.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    } else if (localPath != null &&
        localPath.isNotEmpty &&
        fileName != null &&
        fileName.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          localPath,
          filename: fileName,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = await _decode(response);

    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to create assignment'),
      );
    }

    final data = body['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(body['data'] as Map<String, dynamic>)
        : Map<String, dynamic>.from(body);
    if (data.isEmpty) {
      throw Exception(
        'Unexpected create assignment response (${response.statusCode})',
      );
    }
    return data;
  }

  static Future<List<Map<String, dynamic>>> getAssignmentSubmissions({
    required String assignmentId,
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/assignments/$assignmentId/submissions'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(
          body,
          fallback: 'Failed to load assignment submissions',
        ),
      );
    }

    final submissions = body is Map<String, dynamic>
        ? body['data'] ?? body['submissions']
        : body;
    if (submissions is! List) {
      throw Exception(
        'Unexpected assignment submissions response (${response.statusCode})',
      );
    }

    return submissions.map<Map<String, dynamic>>((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  // Student Assignments Endpoints
  
  static Future<List<Map<String, dynamic>>> getStudentAssignments({
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/student/assignments'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(
          body,
          fallback: 'Failed to load assignments',
        ),
      );
    }

    // Handle both array and wrapped response
    final assignments = body is List
        ? body
        : body is Map<String, dynamic>
        ? body['data'] ?? body['assignments'] ?? [body]
        : [body];
    
    if (assignments is! List) {
      throw Exception('Unexpected assignments response (${response.statusCode})');
    }

    return assignments.map<Map<String, dynamic>>((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  static Future<Map<String, dynamic>> getStudentAssignmentDetail({
    required String assignmentId,
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/student/assignments/$assignmentId'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(
          body,
          fallback: 'Failed to load assignment details',
        ),
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected assignment detail response (${response.statusCode})');
    }

    return body;
  }

  static Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    required String fileName,
    required String localPath,
    String? token,
  }) async {
    token ??= await _readToken();
    final request = http.MultipartRequest(
      'POST',
      _uri('/student/assignments/$assignmentId/submit'),
    );

    request.headers.addAll(_headers(token: token, contentType: ''));

    try {
      request.files.add(
        await http.MultipartFile.fromPath('file', localPath, filename: fileName),
      );
    } catch (e) {
      throw Exception('Failed to read file: ${e.toString()}');
    }

    final response = await request.send();
    final body = await _decode(await http.Response.fromStream(response));

    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(
          body,
          fallback: 'Failed to submit assignment',
        ),
      );
    }

    // Extract data from response
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    if (body is Map<String, dynamic>) {
      return body;
    }

    throw Exception('Unexpected submit assignment response (${response.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> getStudentSubmissions({
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/student/submissions'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(
        _messageFromBody(
          body,
          fallback: 'Failed to load submissions',
        ),
      );
    }

    // Extract submissions list from response
    List<Map<String, dynamic>> submissions = [];
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        submissions = data.map<Map<String, dynamic>>((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
      }
    } else if (body is List) {
      submissions = body.map<Map<String, dynamic>>((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    }

    return submissions;
  }

  static Future<Map<String, dynamic>> startAttendanceSession({
    required String courseId,
    required String lectureId,
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.post(
      _uri('/attendance/start'),
      headers: _headers(token: token),
      body: jsonEncode({
        'course_id': courseId,
        'courseId': courseId,
        'lecture_id': lectureId,
        'lectureId': lectureId,
        'section_id': lectureId,
        'sectionId': lectureId,
      }),
    );

    final body = await _decode(response);
    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Unexpected attendance session response (${response.statusCode})',
      );
    }

    return body;
  }

  static Future<Map<String, dynamic>> closeAttendanceSession({
    required String sessionId,
    String? token,
    String? sessionToken,
  }) async {
    token ??= await _readToken();
    final response = await http.post(
      _uri('/attendance/close'),
      headers: _headers(token: token),
      body: jsonEncode({
        'session_id': sessionId,
        'sessionId': sessionId,
        if (sessionToken != null && sessionToken.isNotEmpty)
          'token': sessionToken,
      }),
    );

    final body = await _decode(response);
    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Unexpected attendance close response (${response.statusCode})',
      );
    }

    return body;
  }

  static Future<Map<String, dynamic>> getAttendanceSession({
    required String sessionId,
    String? token,
  }) async {
    token ??= await _readToken();
    final response = await http.get(
      _uri('/attendance/session/$sessionId'),
      headers: _headers(token: token, contentType: null),
    );

    final body = await _decode(response);
    if (!_isSuccessStatus(response.statusCode) ||
        body is! Map<String, dynamic>) {
      throw Exception(
        _messageFromBody(body, fallback: 'Failed to load attendance session'),
      );
    }

    return body;
  }

  static Map<String, dynamic> _normalizeCourseFile(Map<String, dynamic> map) {
    final fileName =
        map['file_name']?.toString() ?? map['name']?.toString() ?? '';
    final extension = _fileExtension(
      fileName,
      fallback: map['file_type']?.toString(),
    );

    return {
      ...map,
      'courseId':
          map['course_id']?.toString() ?? map['courseId']?.toString() ?? '',
      'name': fileName,
      'extensionLabel': extension,
      'sizeLabel': _formatBytes(map['file_size']),
      'uploadedAtLabel': _formatDateLabel(map['uploaded_at']?.toString()),
      'category_id': _resolveCategoryId(map, fileName),
      'category': _resolveCategoryLabel(map, fileName),
      'remoteUrl':
          map['download_url']?.toString() ?? map['file_url']?.toString(),
      'localPath': map['localPath']?.toString(),
    };
  }

  static int _resolveCategoryId(Map<String, dynamic> map, String fileName) {
    final parsed = int.tryParse(map['category_id']?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }
    switch (_resolveCategoryLabel(map, fileName)) {
      case 'assignment':
        return 1;
      case 'exam':
        return 2;
      case 'material':
        return 3;
      default:
        return 0;
    }
  }

  static String _resolveCategoryLabel(
    Map<String, dynamic> map,
    String fileName,
  ) {
    final raw = map['category']?.toString().trim().toLowerCase();
    if (raw == 'assignment' || raw == 'exam' || raw == 'material') {
      return raw!;
    }
    if (raw == 'lecture') {
      return 'material';
    }
    return _inferFileCategory(fileName);
  }

  static List<Map<String, dynamic>> _groupGradesBySemester(
    List<Map<String, dynamic>> grades,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final grade in grades) {
      final key = _joinNonEmpty([
        grade['academic_year']?.toString(),
        grade['term']?.toString(),
      ], separator: ' - ');
      grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(grade);
    }

    return grouped.entries.map((entry) {
      final items = entry.value;
      return {
        'semester': entry.key,
        'courses': items.map<Map<String, dynamic>>((grade) {
          return {
            ...grade,
            'id': grade['course_code']?.toString() ?? '',
            'name': grade['course_name']?.toString() ?? '',
            'grade': grade['grade_symbol']?.toString() ?? '',
          };
        }).toList(),
      };
    }).toList();
  }

  static String _resolveAnnouncementImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) {
      return '';
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (raw.startsWith('/')) {
      return _baseUri.resolve(raw).toString();
    }
    if (!raw.contains('/')) {
      return _uri('/announcements/image/$raw').toString();
    }
    return _baseUri.resolve(raw).toString();
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _dayLabel(dynamic rawDay) {
    final normalized = rawDay?.toString().trim() ?? '';
    const dayNames = <int, String>{
      0: 'Sunday',
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    final numeric = int.tryParse(normalized);
    if (numeric != null && dayNames.containsKey(numeric)) {
      return dayNames[numeric]!;
    }

    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return '${normalized[0].toUpperCase()}${normalized.substring(1).toLowerCase()}';
  }

  static String _formatTimeRange(dynamic start, dynamic end) {
    final startLabel = start?.toString() ?? '';
    final endLabel = end?.toString() ?? '';
    if (startLabel.isEmpty && endLabel.isEmpty) {
      return '';
    }
    return '$startLabel - $endLabel';
  }

  static String _joinNonEmpty(List<String?> parts, {String separator = ' • '}) {
    return parts
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(separator);
  }

  static String _fileExtension(String fileName, {String? fallback}) {
    final segment = fileName.split('.').last.trim();
    if (fileName.contains('.') && segment.isNotEmpty) {
      return segment.toUpperCase();
    }

    if (fallback != null && fallback.contains('/')) {
      return fallback.split('/').last.toUpperCase();
    }

    return 'FILE';
  }

  static String _formatBytes(dynamic rawSize) {
    final bytes = rawSize is num
        ? rawSize.toDouble()
        : double.tryParse(rawSize?.toString() ?? '');
    if (bytes == null || bytes <= 0) {
      return '';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes;
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final decimals = unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  static String _formatDateLabel(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return rawDate;
    }

    return DateFormat('MMM d, y').format(parsed.toLocal());
  }

  static String _inferFileCategory(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('exam') ||
        lower.contains('midterm') ||
        lower.contains('final')) {
      return 'exam';
    }
    if (lower.contains('assignment') || lower.contains('worksheet')) {
      return 'assignment';
    }
    return 'material';
  }

  static List<dynamic>? _extractInstructorCourses(Map<String, dynamic> body) {
    final direct = body['courses'];
    if (direct is List) {
      return direct;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['courses'];
      if (nested is List) {
        return nested;
      }
    }

    return null;
  }
}
