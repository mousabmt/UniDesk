class MockApi {
  // simulate network delay
  static Future<void> _delay() =>
      Future.delayed(const Duration(seconds: 1));

  // Auth
  static Future<Map<String, dynamic>> login(
      String userId, String password) async {
    await _delay();

    if (userId == 'student@aabu.edu.jo' && password == '1234') {
      return {
        'success': true,
        'token': 'mock_token_xyz_123',
        'role': 'student',
        'user': {
          'id': '2021001',
          'name': 'Mousa Al-Ahmad',
          'email': 'student@aabu.edu.jo',
          'gpa': 3.7,
          'credits':90,
          'totalCredits': 133,
          'completionPrecentage':133/96*100,
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

    return {
      'success': false,
      'message': 'Invalid ID or password',
    };
  }

  // Courses
  static Future<List<Map<String, dynamic>>> getCourses() async {
    await _delay();
    return [
      {
        'id': 'CS101',
        'name': 'Introduction to Programming',
        'instructor': 'Dr. Ahmad',
        'credits': 3,
        'grade': 'A',
      },
      {
        'id': 'CS201',
        'name': 'Data Structures',
        'instructor': 'Dr. Sara',
        'credits': 3,
        'grade': 'B+',
      },
      {
        'id': 'MATH101',
        'name': 'Calculus I',
        'instructor': 'Dr. Khalid',
        'credits': 3,
        'grade': 'A-',
      },
    ];
  }

  // Schedule
  static Future<List<Map<String, dynamic>>> getSchedule() async {
    await _delay();
    return [
      {
        'day': 'Sunday',
        'courses': [
          {'name': 'CS101', 'time': '08:00 - 09:30', 'room': 'A101'},
          {'name': 'MATH101', 'time': '10:00 - 11:30', 'room': 'B203'},
        ],
      },
      {
        'day': 'Monday',
        'courses': [
          {'name': 'CS201', 'time': '09:00 - 10:30', 'room': 'C305'},
        ],
      },
    ];
  }

  // Student Profile
  static Future<Map<String, dynamic>> getProfile() async {
    await _delay();
    return {
      'id': '2021001',
      'name': 'Mousab Al-Ahmad',
      'email': 'student@aabu.edu.jo',
      'major': 'Computer Science',
      'year': 3,
      'gpa': 3.7,
      'credits': 90,
          'totalHours': 133,
          'completionPrecentage':133/96*100,
    };
  }
// ads
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
}