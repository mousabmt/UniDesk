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

  // ─── ASSIGNMENTS DATA ────────────────────────────────────────────────────────
  // Fields match the "Add Assignment" form:
  //   title, description, dueDate, attachedFile (optional),
  //   totalPoints, instructions (optional)
  // curl : POST https://api.unidesk.local/courses/{courseId}/assignments
  static final Map<String, List<Map<String, dynamic>>> _courseAssignments = {
    '120414': [
      {
        'id': 'a-120414-1',
        'courseId': '120414',
        'title': 'Assignment 1',
        'topic': 'Arrays & Linked Lists',
        'sectionId': '1',
        'description':'Implement a singly linked list and an array-based stack.',
        'dueDateLabel': 'May 20, 2024',
        'dueDate': '2024-05-20T23:59:00Z',
        'totalPoints': 100,
        'instructions':
            'Submit a single .pdf file. Late submissions will not be accepted.',
        'attachedFile': {
          'id': 'af-120414-1',
          'name': 'assignment_1.pdf',
          'extensionLabel': 'PDF',
          'sizeLabel': '1.8 MB',
          'url': 'https://api.unidesk.local/files/af-120414-1',
        },
        'submittedCount': 42,
        'totalStudents': 62,
        'status': 'active',
      },
      {
        'id': 'a-120414-2',
        'courseId': '120414',
        'title': 'Assignment 2',
        'topic': 'Stacks & Queues',
        'sectionId': '1',
        'description': 'Implement a queue using two stacks.',
        'dueDateLabel': 'May 28, 2024',
        'dueDate': '2024-05-28T23:59:00Z',
        'totalPoints': 100,
        'instructions': null,
        'attachedFile': {
          'id': 'af-120414-2',
          'name': 'assignment_2.pdf',
          'extensionLabel': 'PDF',
          'sizeLabel': '2.0 MB',
          'url': 'https://api.unidesk.local/files/af-120414-2',
        },
        'submittedCount': 30,
        'totalStudents': 62,
        'status': 'active',
      },
      {
        'id': 'a-120414-3',
        'courseId': '120414',
        'title': 'Assignment 3',
        'topic': 'Trees',
        'sectionId': '1',
        'description': 'Please solve all the questions in the attached file.',
        'dueDateLabel': 'Jun 5, 2024',
        'dueDate': '2024-06-05T23:59:00Z',
        'totalPoints': 100,
        'instructions': null,
        'attachedFile': null,
        'submittedCount': 0,
        'totalStudents': 62,
        'status': 'active',
      },
    ],
    '132120': [
      {
        'id': 'a-132120-1',
        'courseId': '132120',
        'title': 'Assignment 1',
        'topic': 'Limits & Continuity',
        'sectionId': '3',
        'description': 'Solve the limit problems in the attached worksheet.',
        'dueDateLabel': 'May 22, 2024',
        'dueDate': '2024-05-22T23:59:00Z',
        'totalPoints': 50,
        'instructions': 'Show all working steps clearly.',
        'attachedFile': {
          'id': 'af-132120-1',
          'name': 'limits_worksheet.pdf',
          'extensionLabel': 'PDF',
          'sizeLabel': '1.3 MB',
          'url': 'https://api.unidesk.local/files/af-132120-1',
        },
        'submittedCount': 55,
        'totalStudents': 62,
        'status': 'active',
      },
      {
        'id': 'a-132120-2',
        'courseId': '132120',
        'title': 'Assignment 2',
        'topic': 'Derivatives',
        'sectionId': '3',
        'description': 'Differentiate the given functions and show your work.',
        'dueDateLabel': 'Jun 1, 2024',
        'dueDate': '2024-06-01T23:59:00Z',
        'totalPoints': 50,
        'instructions': null,
        'attachedFile': null,
        'submittedCount': 10,
        'totalStudents': 62,
        'status': 'active',
      },
    ],
  };

  static final Map<String, List<Map<String, dynamic>>> _assignmentSubmissions =
      {
        'a-120414-1': [
          {
            'id': 'sub-001',
            'assignmentId': 'a-120414-1',
            'studentId': '2021002',
            'studentName': 'Sara Ali',
            'initials': 'SA',
            'submittedAtLabel': 'May 14, 2024',
            'submittedAt': '2024-05-14T14:22:00Z',
            'status': 'submitted',
            'grade': null,
            'file': {
              'id': 'file-sub-001',
              'name': 'sara_ali_assignment1.pdf',
              'extensionLabel': 'PDF',
              'sizeLabel': '1.2 MB',
              'url': 'https://api.unidesk.local/files/file-sub-001',
            },
          },
          {
            'id': 'sub-002',
            'assignmentId': 'a-120414-1',
            'studentId': '2021010',
            'studentName': 'Omar Khaled',
            'initials': 'OK',
            'submittedAtLabel': 'May 13, 2024',
            'submittedAt': '2024-05-13T09:45:00Z',
            'status': 'submitted',
            'grade': null,
            'file': {
              'id': 'file-sub-002',
              'name': 'omar_khaled_assignment1.pdf',
              'extensionLabel': 'PDF',
              'sizeLabel': '980 KB',
              'url': 'https://api.unidesk.local/files/file-sub-002',
            },
          },
        ],
        'a-120414-2': [
          {
            'id': 'sub-003',
            'assignmentId': 'a-120414-2',
            'studentId': '2021001',
            'studentName': 'Mousab Al-Ahmad',
            'initials': 'MA',
            'submittedAtLabel': 'May 20, 2024',
            'submittedAt': '2024-05-20T11:10:00Z',
            'status': 'submitted',
            'grade': null,
            'file': {
              'id': 'file-sub-003',
              'name': 'mousab_assignment2.pdf',
              'extensionLabel': 'PDF',
              'sizeLabel': '2.1 MB',
              'url': 'https://api.unidesk.local/files/file-sub-003',
            },
          },
        ],
        'a-120414-3': [],
        'a-132120-1': [
          {
            'id': 'sub-004',
            'assignmentId': 'a-132120-1',
            'studentId': '2021010',
            'studentName': 'Omar Nasser',
            'initials': 'ON',
            'submittedAtLabel': 'May 18, 2024',
            'submittedAt': '2024-05-18T16:00:00Z',
            'status': 'submitted',
            'grade': null,
            'file': {
              'id': 'file-sub-004',
              'name': 'omar_nasser_limits.pdf',
              'extensionLabel': 'PDF',
              'sizeLabel': '1.5 MB',
              'url': 'https://api.unidesk.local/files/file-sub-004',
            },
          },
        ],
        'a-132120-2': [],
      };

  // ─── AUTH ────────────────────────────────────────────────────────────────────
  // POST https://api.unidesk.local/auth/login
  // body: { "userId": "...", "password": "..." }
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

  // ─── STUDENT: COURSES ────────────────────────────────────────────────────────
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

  // ─── SCHEDULE ────────────────────────────────────────────────────────────────
  // GET https://api.unidesk.local/schedule/{day}
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
            'instructor': 'Mousab tamari',
          },
          {
            'id': '132120',
            'name': 'Calculus I',
            'time': '10:00 - 11:30',
            'room': 'B203',
            'instructor': 'ahood hacker',
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
            'instructor': 'abdullah php',
          },
        ],
      },
    ];
  }

  // ─── STUDENT PROFILE ─────────────────────────────────────────────────────────
  // GET https://api.unidesk.local/profile/{userId}
  static Future<Map<String, dynamic>> getProfile() async {
    return {
      'id': '2021001',
      'name': 'Mousab Al-Ahmad',
      'email': 'student@aabu.edu.jo',
      'personal_email': 'mousabtamari0799@gmail.com',
      'major': 'Computer Science',
      'year': 3,
      'gpa': 3.7,
      'credits': 90,
      'totalHours': 133,
      'address': 'Amman,tabarbor',
      'identifiers': ['07914214142', '123456789'],
    };
  }

  // ─── ADS ─────────────────────────────────────────────────────────────────────
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

  // ─── ACADEMIC PROGRESS ───────────────────────────────────────────────────────
  // GET https://api.unidesk.local/profile/{userId}/progress
  static Future<Map<String, dynamic>> getAcademicProgress() async {
    return {
      'completed_courses': [
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

  // ─── CALENDAR ────────────────────────────────────────────────────────────────
  // GET https://api.unidesk.local/calendar?month=YYYY-MM
  static Future<Map<String, dynamic>> getCalenderEvents() async {
    return {
      'lectures': [
        {
          'id': 'l1',
          'course_id': 'CS101',
          'course_name': 'Introduction to CS',
          'type': 'lecture',
          'room': 'Room 201',
          'building': 'Science Hall',
          'start_time': '2026-03-05T09:00:00Z',
          'end_time': '2026-03-05T10:30:00Z',
          'instructor': 'Dr. Smith',
        },
        {
          'id': 'l2',
          'course_id': 'MA101',
          'course_name': 'Calculus I',
          'type': 'discussion',
          'room': 'Room 105',
          'building': 'Math Building',
          'start_time': '2026-03-05T11:00:00Z',
          'end_time': '2026-03-05T12:00:00Z',
          'instructor': 'Dr. Johnson',
        },
      ],
      'assignments': [
        {
          'id': 'a1',
          'course_id': 'CS101',
          'course_name': 'Introduction to CS',
          'title': 'Project Proposal',
          'due_date': '2026-03-05T23:59:00Z',
          'type': 'assignment',
          'status': 'pending',
        },
        {
          'id': 'a2',
          'course_id': 'MA101',
          'course_name': 'Calculus I',
          'title': 'Midterm Exam',
          'due_date': '2026-03-05T10:00:00Z',
          'type': 'exam',
          'status': 'pending',
        },
      ],
    };
  }

  // GET https://api.unidesk.local/calendar/day?date=YYYY-MM-DD
  static Future<Map<String, dynamic>> getCalenderEventsForDate(
    DateTime date,
  ) async {
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

    return {
      'assignments': filterList(base['assignments'] ?? [], 'due_date'),
      'lectures': filterList(base['lectures'] ?? [], 'start_time'),
    };
  }

  // ─── INSTRUCTOR: COURSES ─────────────────────────────────────────────────────
  // GET https://api.unidesk.local/courses/{instructorId}
  static Future<Map<String, dynamic>> getInstructorCourses(
    String instructorId,
  ) async {
    final courses = _instructorCourses[instructorId];
    if (courses == null) {
      return {'success': false, 'message': 'No courses found for instructor'};
    }
    return {
      'success': true,
      'data': courses.map((c) => Map<String, dynamic>.from(c)).toList(),
    };
  }

  static Future<Map<String, dynamic>> getInstructorCourseDetails({
    required String instructorId,
    required String courseId,
  }) async {
    final courses = _instructorCourses[instructorId];
    if (courses == null) {
      return {'success': false, 'message': 'No courses found for instructor'};
    }

    Map<String, dynamic>? course;
    for (final item in courses) {
      if (item['id']?.toString() == courseId) {
        course = Map<String, dynamic>.from(item);
        break;
      }
    }

    if (course == null) {
      return {'success': false, 'message': 'Course not found'};
    }

    final lectureId = course['lectureId']?.toString() ?? '';
    final rosterKey = _courseRosterKey(courseId, lectureId);
    final students = _courseStudents[rosterKey] ?? const [];
    final details = _instructorCourseDetails[courseId];

    if (details == null) {
      return {'success': false, 'message': 'Course details not found'};
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
        'students': students.map((s) => Map<String, dynamic>.from(s)).toList(),
      },
    };
  }

  static Future<Map<String, dynamic>> uploadInstructorCourseFile({
    required String instructorId,
    required String courseId,
    required String fileName,
    required String category,
    int? categoryId,
    required String extensionLabel,
    String? localPath,
  }) async {
    final courses = _instructorCourses[instructorId];
    if (courses == null) {
      return {'success': false, 'message': 'No courses found for instructor'};
    }

    final belongsToInstructor = courses.any(
      (c) => c['id']?.toString() == courseId,
    );
    if (!belongsToInstructor) {
      return {
        'success': false,
        'message': 'Course not found for this instructor',
      };
    }

    final details = _instructorCourseDetails[courseId];
    if (details == null) {
      return {'success': false, 'message': 'Course details not found'};
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
      'category_id': categoryId,
      'localPath': localPath,
    };

    files.insert(0, newFile);
    details['files'] = files;

    final summary = Map<String, dynamic>.from(details['summary'] ?? const {});
    summary['filesCount'] = files.length;
    details['summary'] = summary;

    return {'success': true, 'data': newFile};
  }

  // ─── INSTRUCTOR: STUDENTS ────────────────────────────────────────────────────
  // GET https://api.unidesk.local/courses/{courseId}/{lectureId}/students
  static Future<Map<String, dynamic>> getCourseStudents(
    String courseId,
    String lectureId,
  ) async {
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
      'data': students.map((s) => Map<String, dynamic>.from(s)).toList(),
    };
  }

  // ─── INSTRUCTOR: ASSIGNMENTS ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getInstructorAssignments() async {
    final assignments = _courseAssignments.values
        .expand((items) => items)
        .map(_normalizeInstructorAssignment)
        .toList();
    return {'success': true, 'data': assignments};
  }

  // GET https://api.unidesk.local/courses/{courseId}/assignments
  static Future<Map<String, dynamic>> getCourseAssignments(
    String courseId,
  ) async {
    final assignments = _courseAssignments[courseId];
    if (assignments == null) {
      return {
        'success': false,
        'message': 'No assignments found for this course',
      };
    }
    return {
      'success': true,
      'data': assignments.map((a) => Map<String, dynamic>.from(a)).toList(),
    };
  }

  // GET https://api.unidesk.local/courses/{courseId}/assignments/{assignmentId}/submissions
  static Future<Map<String, dynamic>> getAssignmentSubmissions({
    required String courseId,
    required String assignmentId,
  }) async {
    final courseAssignments = _courseAssignments[courseId];
    if (courseAssignments == null ||
        !courseAssignments.any((a) => a['id'] == assignmentId)) {
      return {'success': false, 'message': 'Assignment not found'};
    }

    final submissions = _assignmentSubmissions[assignmentId] ?? [];
    return {
      'success': true,
      'data': submissions.map((s) => Map<String, dynamic>.from(s)).toList(),
    };
  }

  static Future<Map<String, dynamic>> getInstructorAssignmentSubmissions(
    String assignmentId,
  ) async {
    for (final assignments in _courseAssignments.values) {
      if (assignments.any((item) => item['id']?.toString() == assignmentId)) {
        final submissions = _assignmentSubmissions[assignmentId] ?? [];
        return {
          'success': true,
          'data': submissions.map(_normalizeSubmission).toList(),
        };
      }
    }
    return {'success': false, 'message': 'Assignment not found'};
  }

  static Future<Map<String, dynamic>> gradeAssignmentSubmission({
    required String assignmentId,
    required String submissionId,
    required double score,
  }) async {
    final submissions = _assignmentSubmissions[assignmentId];
    if (submissions == null) {
      return {'success': false, 'message': 'Assignment not found'};
    }

    for (var index = 0; index < submissions.length; index++) {
      final submission = submissions[index];
      if (submission['id']?.toString() != submissionId) {
        continue;
      }

      final updated = <String, dynamic>{
        ...submission,
        'grade': score,
        'score': score,
        'feedback': submission['feedback'],
        'status': 'graded',
      };
      submissions[index] = updated;
      _assignmentSubmissions[assignmentId] = submissions;
      return {'success': true, 'data': _normalizeSubmission(updated)};
    }

    return {'success': false, 'message': 'Submission not found'};
  }

  // POST https://api.unidesk.local/courses/{courseId}/assignments
  // body: {
  //   "title": "...",
  //   "description": "...",
  //   "dueDate": "YYYY-MM-DDTHH:mm:ssZ",
  //   "totalPoints": 100,
  //   "instructions": "...",          // optional
  //   "attachedFile": {               // optional — sent as multipart or base64
  //     "name": "assignment_4.pdf",
  //     "sizeLabel": "2.4 MB",
  //     "extensionLabel": "PDF"
  //   }
  // }
  static Future<Map<String, dynamic>> createAssignment({
    required String courseId,
    String? sectionId,
    required String title,
    required String description,
    required String dueDate,
    required int totalPoints,
    bool isActive = true,
    Map<String, dynamic>?
    attachedFile, // { name, sizeLabel, extensionLabel, localPath? }
  }) async {
    final assignments = _courseAssignments[courseId];
    if (assignments == null) {
      return {'success': false, 'message': 'Course not found'};
    }

    final due = DateTime.parse(dueDate).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final assignmentId = 'a-$courseId-${assignments.length + 1}';
    final now = DateTime.now();
    final totalStudents = _studentsEnrolledForCourse(courseId);

    Map<String, dynamic>? filePayload;
    if (attachedFile != null) {
      final fileId = 'af-$courseId-${now.millisecondsSinceEpoch}';
      final ext =
          (attachedFile['extensionLabel'] as String? ??
                  (attachedFile['name'] as String? ?? '').split('.').last)
              .toUpperCase();
      filePayload = {
        'id': fileId,
        'name': attachedFile['name'],
        'extensionLabel': ext,
        'sizeLabel': attachedFile['sizeLabel'] ?? 'Unknown',
        'url': 'https://api.unidesk.local/files/$fileId',
        if (attachedFile['localPath'] != null)
          'localPath': attachedFile['localPath'],
      };
    }

    final newAssignment = <String, dynamic>{
      'id': assignmentId,
      'courseId': courseId,
      'sectionId': sectionId ?? '',
      'title': title,
      'description': description,
      'dueDateLabel': '${months[due.month - 1]} ${due.day}, ${due.year}',
      'dueDate': dueDate,
      'totalPoints': totalPoints,
      'attachedFile': filePayload,
      'submittedCount': 0,
      'totalStudents': totalStudents,
      'status': isActive ? 'active' : 'inactive',
    };

    assignments.add(newAssignment);
    _assignmentSubmissions[assignmentId] = [];
    final details = _instructorCourseDetails[courseId];
    if (details != null) {
      final summary = Map<String, dynamic>.from(details['summary'] ?? const {});
      summary['assignmentsCount'] = assignments.length;
      details['summary'] = summary;
    }

    return {'success': true, 'data': _normalizeInstructorAssignment(newAssignment)};
  }

  // ─── STUDENT: SUBMIT ASSIGNMENT ──────────────────────────────────────────────
  // POST https://api.unidesk.local/courses/{courseId}/assignments/{assignmentId}/submissions
  // headers: { "Authorization": "Bearer <student_token>" }
  // body: { "fileName": "...", "sizeLabel": "..." }
  static Future<Map<String, dynamic>> submitAssignment({
    required String courseId,
    required String assignmentId,
    required String studentId,
    required String studentName,
    required String fileName,
    required String sizeLabel,
    String? localPath,
  }) async {
    final courseAssignments = _courseAssignments[courseId];
    if (courseAssignments == null ||
        !courseAssignments.any((a) => a['id'] == assignmentId)) {
      return {'success': false, 'message': 'Assignment not found'};
    }

    final submissions = _assignmentSubmissions[assignmentId] ?? [];

    final alreadySubmitted = submissions.any(
      (s) => s['studentId'] == studentId,
    );
    if (alreadySubmitted) {
      return {'success': false, 'message': 'Already submitted'};
    }

    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final initials = studentName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final newSubmission = <String, dynamic>{
      'id': 'sub-${submissions.length + 1}-${now.millisecondsSinceEpoch}',
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'initials': initials,
      'submittedAtLabel': '${months[now.month - 1]} ${now.day}, ${now.year}',
      'submittedAt': now.toIso8601String(),
      'status': 'submitted',
      'grade': null,
      'file': {
        'id': 'file-${now.millisecondsSinceEpoch}',
        'name': fileName,
        'extensionLabel': fileName.contains('.')
            ? fileName.split('.').last.toUpperCase()
            : 'FILE',
        'sizeLabel': sizeLabel,
        'url':
            'https://api.unidesk.local/files/file-${now.millisecondsSinceEpoch}',
        'localPath': localPath,
      },
    };

    submissions.add(newSubmission);
    _assignmentSubmissions[assignmentId] = submissions;

    // bump submittedCount on the parent assignment
    for (final a in courseAssignments) {
      if (a['id'] == assignmentId) {
        a['submittedCount'] = (a['submittedCount'] as int) + 1;
        break;
      }
    }

    return {'success': true, 'data': Map<String, dynamic>.from(newSubmission)};
  }

  static Map<String, dynamic> _normalizeInstructorAssignment(
    Map<String, dynamic> raw,
  ) {
    final attachment = raw['attachedFile'] is Map
        ? Map<String, dynamic>.from(raw['attachedFile'] as Map)
        : null;
    return {
      'id': raw['id']?.toString() ?? '',
      'course_id': raw['courseId']?.toString() ?? '',
      'section_id': raw['sectionId']?.toString() ?? '',
      'instructor_id': _defaultInstructorId,
      'title': raw['title']?.toString() ?? '',
      'description': raw['description']?.toString() ?? '',
      'file_name': attachment?['name']?.toString(),
      'file_path': attachment?['localPath']?.toString(),
      'file_url': attachment?['url']?.toString(),
      'due_date': raw['dueDate']?.toString() ?? '',
      'max_score': raw['totalPoints'] ?? 100,
    };
  }

  static Map<String, dynamic> _normalizeSubmission(Map<String, dynamic> raw) {
    return {
      'id': raw['id']?.toString() ?? '',
      'assignment_id': raw['assignmentId']?.toString() ?? '',
      'student_id': raw['studentId']?.toString() ?? '',
      'student_name': raw['studentName']?.toString() ?? '',
      'submitted_at': raw['submittedAt']?.toString() ?? '',
      'status': raw['status']?.toString() ?? 'submitted',
      'score': raw['score'] ?? raw['grade'],
      'grade': raw['grade'] ?? raw['score'],
      'feedback': raw['feedback']?.toString(),
      if (raw['file'] is Map) 'file': Map<String, dynamic>.from(raw['file'] as Map),
    };
  }

  // ─── ATTENDANCE ──────────────────────────────────────────────────────────────
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
  static Future<Map<String, dynamic>> closeAttendanceSession(
    String token,
  ) async {
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
    required String studentId,
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
      return {
        'success': false,
        'message': 'Student is not enrolled in this lecture',
      };
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

  // ─── HELPERS ─────────────────────────────────────────────────────────────────
  static String _courseRosterKey(String courseId, String lectureId) {
    return '$courseId::$lectureId';
  }

  static int _studentsEnrolledForCourse(String courseId) {
    for (final courses in _instructorCourses.values) {
      for (final course in courses) {
        if (course['id']?.toString() == courseId) {
          final value = course['studentsEnrolled'];
          if (value is int) {
            return value;
          }
          return int.tryParse(value?.toString() ?? '') ?? 0;
        }
      }
    }
    return 0;
  }

  static String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(32, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
