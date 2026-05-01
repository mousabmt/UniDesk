import 'dart:math';

class MockApi {
  static const String _defaultInstructorId = 'D001';
// route call is : GET https://api.unidesk.local/courses/{instructorId}  
  static final Map<String, List<Map<String, dynamic>>> _instructorCourses = {
    _defaultInstructorId: [
      {
        'id': '120414',
        'name': 'Introduction to Programming',
        'credits': 3,
        'studentsEnrolled': 4,
        'lectureId': '1',
        'term': 'Spring 2024',
        'sectionLabel': 'Section A',
      },
      {
        'id': '132120',
        'name': 'Calculus I',
        'credits': 3,
        'studentsEnrolled': 3,
        'lectureId': '3',
        'term': 'Spring 2024',
        'sectionLabel': 'Section B',
      },
    ],
  };
  static final Map<String, Map<String, dynamic>> _instructorCourseDetails = {
    '120414': {
      'summary': {
        'averageAttendanceLabel': '85%',
        'assignmentsCount': 4,
        'filesCount': 3,
      },
      'upcomingLecture': {
        'title': 'Lecture 6 - Hashing',
        'dateLabel': 'May 16, 2024',
        'timeLabel': '10:00 AM - 11:30 AM',
        'locationLabel': 'Room 2203',
      },
      'files': [
        {
          'id': 'f-120414-1',
          'courseId': '120414',
          'name': 'Lecture 5 - Trees.pdf',
          'extensionLabel': 'PDF',
          'sizeLabel': '2.4 MB',
          'uploadedAtLabel': 'May 14, 2024',
          'category': 'lecture',
        },
        {
          'id': 'f-120414-2',
          'courseId': '120414',
          'name': 'Sorting Algorithms.pptx',
          'extensionLabel': 'PPTX',
          'sizeLabel': '5.1 MB',
          'uploadedAtLabel': 'May 10, 2024',
          'category': 'lecture',
        },
        {
          'id': 'f-120414-3',
          'courseId': '120414',
          'name': 'Midterm Review.pdf',
          'extensionLabel': 'PDF',
          'sizeLabel': '1.9 MB',
          'uploadedAtLabel': 'May 7, 2024',
          'category': 'exam',
        },
      ],
    },
    '132120': {
      'summary': {
        'averageAttendanceLabel': '91%',
        'assignmentsCount': 2,
        'filesCount': 2,
      },
      'upcomingLecture': {
        'title': 'Lecture 8 - Derivatives',
        'dateLabel': 'May 18, 2024',
        'timeLabel': '12:00 PM - 1:30 PM',
        'locationLabel': 'Math Hall / Room 105',
      },
      'files': [
        {
          'id': 'f-132120-1',
          'courseId': '132120',
          'name': 'Worksheet 3.docx',
          'extensionLabel': 'DOCX',
          'sizeLabel': '840 KB',
          'uploadedAtLabel': 'May 13, 2024',
          'category': 'assignment',
        },
        {
          'id': 'f-132120-2',
          'courseId': '132120',
          'name': 'Limits Review.pdf',
          'extensionLabel': 'PDF',
          'sizeLabel': '1.3 MB',
          'uploadedAtLabel': 'May 9, 2024',
          'category': 'lecture',
        },
      ],
    },
  };
// route call is : GET https://api.unidesk.local/courses/{courseId}/{lectureId}/students
  static final Map<String, List<Map<String, dynamic>>> _courseStudents = {
    '120414::1': [
      {
        'id': '2021001',
        'name': 'Mousab Al-Ahmad',
        'email': 'mousab.ahmad@aabu.edu.jo',
        'absences': 2,
        'status': 'enrolled',
        'isPresent': false,
      },
      {
        'id': '2021002',
        'name': 'Sara Al-Khalidi',
        'email': 'sara.khalidi@aabu.edu.jo',
        'absences': 0,
        'status': 'enrolled',
        'isPresent': false,
      },
      {
        'id': '2021003',
        'name': 'Ahmad Al-Zoubi',
        'email': 'ahmad.zoubi@aabu.edu.jo',
        'absences': 4,
        'status': 'enrolled',
        'isPresent': false,
      },
      {
        'id': '2021004',
        'name': 'Lina Haddad',
        'email': 'lina.haddad@aabu.edu.jo',
        'absences': 1,
        'status': 'enrolled',
        'isPresent': false,
      },
    ],
    '132120::3': [
      {
        'id': '2021010',
        'name': 'Omar Nasser',
        'email': 'omar.nasser@aabu.edu.jo',
        'absences': 0,
        'status': 'enrolled',
        'isPresent': false,
      },
      {
        'id': '2021011',
        'name': 'Rana Saleh',
        'email': 'rana.saleh@aabu.edu.jo',
        'absences': 3,
        'status': 'enrolled',
        'isPresent': false,
      },
      {
        'id': '2021012',
        'name': 'Yousef Haddad',
        'email': 'yousef.haddad@aabu.edu.jo',
        'absences': 1,
        'status': 'enrolled',
        'isPresent': false,
      },
    ],
  };

  // Auth
  // POST https://api.unidesk.local/auth/login  body: { "userId": "...", "password": "..." }
static Future<Map<String, dynamic>> login(
  String userId,
  String password,
) async {
  if (userId == 'std' && password == '123') {
    return {
      'success': true,
      'token': 'mock_token_xyz_123',
      'role': 'student',
      'user': {
        'id': '2021001',
        'name': 'Mousa Al-Ahmad',
        'email': 'student@aabu.edu.jo',
        'gpa': 3.7,
        'credits': 90,
        'totalCredits': 133,
        'completionPrecentage': 133 / 96 * 100,
      },
    };
  }

  if (userId == 'admin@aabu.edu.jo' && password == '1234') {
    return {
      'success': true,
      'token': 'mock_token_admin_456',
      'role': 'admin',
      'user': {
        'id': 'ADM001',
        'name': 'Admin User',
        'email': 'admin@aabu.edu.jo',
      },
    };
  }

  // ✅ Moved above the final return
  if (userId == 'dr' && password == '1234') {
    return {
      'success': true,
      'token': 'mock_token_instructor_789',
      'role': 'instructor',
      'user': {
        'id': 'D001',
        'name': 'Dr. Ahmad',
        'email': 'dr.ahmad@aabu.edu.jo',
      },
    };
  }

  return {'success': false, 'message': 'Invalid ID or password'}; 
}
  // Courses
  // GET https://api.unidesk.local/courses/{userId}
  static Future<List<Map<String, dynamic>>> getCourses() async {
    return [
      {
        'id': '120414',
        'name': 'Introduction to Programming',
        'instructor': 'Dr. Ahmad',
        'credits': 3,
        'grade': '95',
        'absences': 2,
      },
      {
        'id': '120313',
        'name': 'Data Structures',
        'instructor': 'Dr. Sara',
        'credits': 3,
        'grade': '91',
        'absences': 0,
      },
      {
        'id': '132120',
        'name': 'Calculus I',
        'instructor': 'Dr. Khalid',
        'credits': 3,
        'grade': '70',
        'absences': 1,
      },
    ];
  }

  // Schedule
  // GET https://api.unidesk.local/schedule/{day}  (e.g., /schedule/monday)
  static Future<List<Map<String, dynamic>>> getSchedule() async {
    return [
      {
        'day': 'Sunday',
        'courses': [
          {
            'id': '120414',
            'name': 'Introduction to Programming',
            'time': '08:00 - 09:30',
            'room': 'A101',
            'instructor': "Mousab tamari",
          },
          {
            'id': '132120',
            'name': 'Calculus I',
            'time': '10:00 - 11:30',
            'room': 'B203',
            'instructor': "ahood hacker",
          },
        ],
      },
      {
        'day': 'Monday',
        'courses': [
          {
            'id': '120313',
            'name': 'Data Structures',
            'time': '09:00 - 10:30',
            'room': 'C305',
            'instructor': "abdullah php",
          },
        ],
      },
    ];
  }

  // Student Profile
  // GET https://api.unidesk.local/profile/{userId}
  static Future<Map<String, dynamic>> getProfile() async {
    return {
      'id': '2021001',
      'name': 'Mousab Al-Ahmad',
      'email': 'student@aabu.edu.jo',
      'personal_email': "mousabtamari0799@gmail.com",
      'major': 'Computer Science',
      'year': 3,
      'gpa': 3.7,
      'credits': 90,
      'totalHours': 133,
      'address': "Amman,tabarbor",
      'identifiers': ["07914214142", "123456789"],
    };
  }

  // ads
  // GET https://api.unidesk.local/ads
  static Future<List<Map<String, dynamic>>> getAds() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {
        'id': '1',
        'title': 'University Open Day',
        'imageUrl': 'https://picsum.photos/seed/ad1/800/300',
        'link': 'https://university.edu/openday',
      },
      {
        'id': '2',
        'title': 'New Library Resources',
        'imageUrl': 'https://picsum.photos/seed/ad2/800/300',
        'link': 'https://university.edu/library',
      },
      {
        'id': '3',
        'title': 'Student Scholarship 2025',
        'imageUrl': 'https://picsum.photos/seed/ad3/800/300',
        'link': 'https://university.edu/scholarship',
      },
    ];
  }

  // GET https://api.unidesk.local/profile/{userId}/progress
  static Future<Map<String, dynamic>> getAcademicProgress() async {
    return {
      "completed_courses": [
        {
          'semester': 'Fall 2021',
          'gpa': 3.5,
          'creditsEarned': 15,
          'totalCredits': 18,
          'courses': [
            {
              'id': '120313',
              'name': 'Introduction to Programming',
              'grade': 'A',
            },
            {'id': '132120', 'name': 'Calculus I', 'grade': 'A-'},
          ],
        },
        {
          'semester': 'Spring 2022',
          'gpa': 3.7,
          'creditsEarned': 18,
          'totalCredits': 18,
          'courses': [
            {'id': '120414', 'name': 'Data Structures', 'grade': 'A'},
            {'id': '132121', 'name': 'Calculus II', 'grade': 'B+'},
          ],
        },
        {
          'semester': 'Fall 2022',
          'gpa': 3.8,
          'creditsEarned': 18,
          'courses': [
            {'id': '120415', 'name': 'Operating Systems', 'grade': 'A'},
            {'id': '132122', 'name': 'Linear Algebra', 'grade': 'A-'},
          ],
        },
        {
          'semester': 'Spring 2023',
          'gpa': 3.9,
          'creditsEarned': 18,
          'courses': [
            {'id': '120416', 'name': 'Database Systems', 'grade': 'A'},
            {'id': '132123', 'name': 'Discrete Mathematics', 'grade': 'A'},
          ],
        },
      ],
    };
  }

  // Calendar (month view): GET https://api.unidesk.local/calendar?month=YYYY-MM   (e.g., 2026-03)
  static Future<Map<String, dynamic>> getCalenderEvents() async {
    return {
      "lectures": [
        {
          "id": "l1",
          "course_id": "CS101",
          "course_name": "Introduction to CS",
          "type": "lecture",
          "room": "Room 201",
          "building": "Science Hall",
          "start_time": "2026-03-05T09:00:00Z",
          "end_time": "2026-03-05T10:30:00Z",
          "instructor": "Dr. Smith",
        },
        {
          "id": "l2",
          "course_id": "MA101",
          "course_name": "Calculus I",
          "type": "discussion",
          "room": "Room 105",
          "building": "Math Building",
          "start_time": "2026-03-05T11:00:00Z",
          "end_time": "2026-03-05T12:00:00Z",
          "instructor": "Dr. Johnson",
        },
      ],

      "assignments": [
        {
          "id": "a1",
          "course_id": "CS101",
          "course_name": "Introduction to CS",
          "title": "Project Proposal",
          "due_date": "2026-03-05T23:59:00Z",
          "type": "assignment",
          "status": "pending",
        },
        {
          "id": "a2",
          "course_id": "MA101",
          "course_name": "Calculus I",
          "title": "Midterm Exam",
          "due_date": "2026-03-05T10:00:00Z",
          "type": "exam",
          "status": "pending",
        },
      ],
    };
  }

  ///  fetching events for a specific calendar day (local date).
  /// It filters the base calendar payload by the provided [date]'s year/month/day.
  /// Real API: GET https://api.unidesk.local/calendar/day?date=YYYY-MM-DD   (e.g., 2026-03-05)
  static Future<Map<String, dynamic>> getCalenderEventsForDate(DateTime date) async {
    final base = await getCalenderEvents();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    List<Map<String, dynamic>> filterList(List items, String timeKey) {
      return items
          .where((e) {
            final t = DateTime.parse(e[timeKey]).toLocal();
            return isSameDay(t, date.toLocal());
          })
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    final assignments = filterList(base["assignments"] ?? [], "due_date");
    final lectures = filterList(base["lectures"] ?? [], "start_time");

    return {
      "assignments": assignments,
      "lectures": lectures,
    };
  }

// ───────────────────INTSTRUCTOR SECTION───────────────────────────────────────────
// GET https://api.unidesk.local/courses/{instructorId}

static Future<Map<String, dynamic>> getInstructorCourses(String instructorId) async {
  final courses = _instructorCourses[instructorId];
  if (courses == null) {
    return {
      'success': false,
      'message': 'No courses found for instructor',
    };
  }

  return {
    'success': true,
    'data': courses.map((course) => Map<String, dynamic>.from(course)).toList(),
  };
}

static Future<Map<String, dynamic>> getInstructorCourseDetails({
  required String instructorId,
  required String courseId,
}) async {
  final courses = _instructorCourses[instructorId];
  if (courses == null) {
    return {
      'success': false,
      'message': 'No courses found for instructor',
    };
  }

  Map<String, dynamic>? course;
  for (final item in courses) {
    if (item['id']?.toString() == courseId) {
      course = Map<String, dynamic>.from(item);
      break;
    }
  }

  if (course == null) {
    return {
      'success': false,
      'message': 'Course details not found',
    };
  }

  final lectureId = course['lectureId']?.toString() ?? '';
  final rosterKey = _courseRosterKey(courseId, lectureId);
  final students = _courseStudents[rosterKey] ?? const [];
  final details = _instructorCourseDetails[courseId];
  if (details == null) {
    return {
      'success': false,
      'message': 'Course details not found',
    };
  }

  return {
    'success': true,
    'data': {
      'course': course,
      'summary': Map<String, dynamic>.from(details['summary'] ?? const {}),
      'upcomingLecture': Map<String, dynamic>.from(
        details['upcomingLecture'] ?? const {},
      ),
      'files': List<Map<String, dynamic>>.from(details['files'] ?? const []),
      'students': students
          .map((student) => Map<String, dynamic>.from(student))
          .toList(),
    },
  };
}

static Future<Map<String, dynamic>> uploadInstructorCourseFile({
  required String instructorId,
  required String courseId,
  required String fileName,
  required String category,
  required String extensionLabel,
  String? localPath,
}) async {
  final courses = _instructorCourses[instructorId];
  if (courses == null) {
    return {
      'success': false,
      'message': 'No courses found for instructor',
    };
  }

  final belongsToInstructor = courses.any(
    (course) => course['id']?.toString() == courseId,
  );
  if (!belongsToInstructor) {
    return {
      'success': false,
      'message': 'Course details not found',
    };
  }

  final details = _instructorCourseDetails[courseId];
  if (details == null) {
    return {
      'success': false,
      'message': 'Course details not found',
    };
  }

  final files = List<Map<String, dynamic>>.from(details['files'] ?? const []);
  final now = DateTime.now();
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final normalizedExtension = extensionLabel.toUpperCase();
  final newFile = <String, dynamic>{
    'id': 'f-$courseId-${files.length + 1}-${now.millisecondsSinceEpoch}',
    'courseId': courseId,
    'name': fileName,
    'extensionLabel': normalizedExtension,
    'sizeLabel': normalizedExtension == 'PPTX' ? '4.8 MB' : '1.2 MB',
    'uploadedAtLabel': '${monthNames[now.month - 1]} ${now.day}, ${now.year}',
    'category': category,
    'localPath': localPath,
  };

  files.insert(0, newFile);
  details['files'] = files;

  final summary = Map<String, dynamic>.from(details['summary'] ?? const {});
  summary['filesCount'] = files.length;
  details['summary'] = summary;

  return {
    'success': true,
    'data': newFile,
  };
}
// GET https://api.unidesk.local/courses/{courseId}/{lectureId}/students
static Future<Map<String, dynamic>> getCourseStudents(String courseId, String lectureId) async {
  final rosterKey = _courseRosterKey(courseId, lectureId);
  final students = _courseStudents[rosterKey];
  if (students == null) {
    return {
      'success': false,
      'message': 'No students found for this lecture',
    };
  }

  return {
    'success': true,
    'data': students.map((student) => Map<String, dynamic>.from(student)).toList(),
  };
}
 
// ─── ATTENDANCE ────────────────────────────────────────────────

// fake in-memory storage
static final Map<String, Map<String, dynamic>> _sessions = {};
static final Set<String> _attendedStudents = {};

// INSTRUCTOR: POST https://api.unidesk.local/attendance/start
// body: { "courseId": "...", "lectureId": "..." }
static Future<Map<String, dynamic>> startAttendanceSession({
  required String courseId,
  required String lectureId,
}) async {
final rosterKey = _courseRosterKey(courseId, lectureId);
  final students = _courseStudents[rosterKey];
  if (students == null) {
    return {'success': false, 'message': 'Lecture roster not found'};
  }

  for (final student in students) {
    student['isPresent'] = false;
  }

  final token = _generateToken();
  final expiresAt = DateTime.now().add(const Duration(minutes: 10));

  _sessions[token] = {
    'token': token,
    'courseId': courseId,
    'lectureId': lectureId,
    'expiresAt': expiresAt.toIso8601String(),
    'isActive': true,
    'rosterKey': rosterKey,
  };

  return {
    'success': true,
    'data': {
      'token': token,
      'courseId': courseId,
      'lectureId': lectureId,
      'expiresAt': expiresAt.toIso8601String(),
    },
  };
}

// INSTRUCTOR: POST https://api.unidesk.local/attendance/close
// body: { "token": "..." }
static Future<Map<String, dynamic>> closeAttendanceSession(String token) async {
  if (!_sessions.containsKey(token)) {
    return {'success': false, 'message': 'Session not found'};
  }
  _sessions[token]!['isActive'] = false;
  return {'success': true, 'message': 'Session closed'};
}

// STUDENT: POST https://api.unidesk.local/attendance/register
// body: { "token": "...", "courseId": "..." }
// headers: { "Authorization": "Bearer <student_token>" }
static Future<Map<String, dynamic>> registerAttendance({
  required String token,
  required String courseId,
  required String studentId, // taken from AuthProvider
}) async {
  if (!_sessions.containsKey(token)) {
    return {'success': false, 'message': 'Invalid QR code'};
  }

  final session = _sessions[token]!;

  final expiresAt = DateTime.parse(session['expiresAt']);
  if (DateTime.now().isAfter(expiresAt)) {
    return {'success': false, 'message': 'QR code has expired'};
  }

  if (!session['isActive']) {
    return {'success': false, 'message': 'Session is closed'};
  }

  if (session['courseId'] != courseId) {
    return {'success': false, 'message': 'Invalid course'};
  }

  final rosterKey = session['rosterKey']?.toString() ?? '';
  final students = _courseStudents[rosterKey];
  if (students == null) {
    return {'success': false, 'message': 'Lecture roster not found'};
  }

  Map<String, dynamic>? matchedStudent;
  for (final student in students) {
    if (student['id']?.toString() == studentId) {
      matchedStudent = student;
      break;
    }
  }

  if (matchedStudent == null) {
    return {'success': false, 'message': 'Student is not enrolled in this lecture'};
  }

  final attendanceKey = '$studentId-$token';
  if (_attendedStudents.contains(attendanceKey)) {
    return {'success': false, 'message': 'Already registered'};
  }

  _attendedStudents.add(attendanceKey);
  matchedStudent['isPresent'] = true;

  return {
    'success': true,
    'message': 'Attendance registered successfully',
    'data': {
      'studentId': studentId,
      'courseId': courseId,
      'lectureId': session['lectureId'],
      'scannedAt': DateTime.now().toIso8601String(),
    },
  };
}

// HELPER
static String _courseRosterKey(String courseId, String lectureId) {
  return '$courseId::$lectureId';
}

static String _generateToken() {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(32, (_) => chars[rand.nextInt(chars.length)]).join();
}
}
