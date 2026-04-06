class MockApi {
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

    return {'success': false, 'message': 'Invalid ID or password'};
  }
    
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
}
