class MockApi {
  // simulate network delay
  static Future<void> _delay() =>
      Future.delayed(const Duration(seconds: 1));

  // Auth
  static Future<Map<String, dynamic>> login(
      String userId, String password) async {
    await _delay();

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
  static Future<List<Map<String, dynamic>>> getSchedule() async {
    await _delay();
    return [
      {
        'day': 'Sunday',
        'courses': [
          {'id': '120414','name': 'Introduction to Programming', 'time': '08:00 - 09:30', 'room': 'A101'},
          {'id': '132120', 'name': 'Calculus I', 'time': '10:00 - 11:30', 'room': 'B203'},
        ],
      },
      {
        'day': 'Monday',
        'courses': [
          {'id': '120313', 'name': 'Data Structures', 'time': '09:00 - 10:30', 'room': 'C305'},
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
      'personal_email':"mousabtamari0799@gmail.com",
      'major': 'Computer Science',
      'year': 3,
      'gpa': 3.7,
      'credits': 90,
          'totalHours': 133,
      'address':"Amman,tabarbor",
      'identifiers':[
        "07914214142",
        "123456789",
      ]
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

  static Future<Map<String, dynamic>> getAcademicProgress() async {
  await _delay();
  return {                                  
    "completed_courses": [
      {
        'semester': 'Fall 2021',
        'gpa': 3.5,
        'creditsEarned': 15,
        'totalCredits': 18,
        'courses': [
          {'id': '120313', 'name': 'Introduction to Programming', 'grade': 'A'},
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
      }
    ],
    
  };
}
     
}