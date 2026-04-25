import 'package:unidesk/features/entities/instructor/pages/course_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/pages/login.dart';
import 'package:unidesk/features/entities/student/pages/gradesPage.dart';
import 'package:unidesk/features/entities/student/pages/home.dart';
import 'package:unidesk/features/entities/student/pages/profile_page.dart';
import 'package:unidesk/features/entities/student/providers_std/profile_provider.dart';
import 'package:unidesk/features/entities/student/pages/currentSemesterPage.dart';
import 'features/entities/student/pages/courses.dart';
import 'features/language/langProvider.dart';
import 'features/auth/authProvider.dart';
import 'features/entities/student/providers_std/course_provider.dart';
import 'features/entities/student/providers_std/annouc_provider.dart';
import 'features/entities/student/providers_std/prevSemesters_provider.dart';
import 'features/entities/student/providers_std/currentSem_provider.dart';
import 'features/entities/student/pages/prevSemesters.dart';
import 'features/entities/student/pages/calenderEvents.dart';
import 'features/entities/student/providers_std/CalenderProvider.dart';
import 'features/entities/student/pages/techinalSupportPage.dart';
import 'package:unidesk/features/entities/instructor/pages/instructorLayout.dart';
import 'package:unidesk/features/entities/instructor/pages/home_DR.dart';
import 'package:unidesk/features/entities/instructor/pages/addfiles.dart';
import 'package:unidesk/features/entities/instructor/pages/Announcements.dart';
import 'package:unidesk/features/entities/instructor/pages/Assignments.dart';
import 'package:unidesk/features/entities/instructor/pages/add_assignment.dart';
import 'package:unidesk/features/entities/instructor/pages/Attendance_Report.dart';
import 'package:unidesk/features/entities/instructor/pages/Messages.dart';
import 'package:unidesk/features/entities/instructor/pages/Profile.dart';
import 'package:unidesk/features/entities/instructor/pages/Reports_Analytics.dart';
import 'package:unidesk/features/entities/instructor/pages/Schodule.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_session_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_students_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/attendance_page.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'features/entities/student/pages/QRScannerRegister.dart';

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LangProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..loadIfNeeded(),
        ),
        ChangeNotifierProvider(
          create: (_) => CoursesProvider()..loadIfNeeded(),
        ),
        ChangeNotifierProvider(create: (_) => AnnoucProvider()),
        ChangeNotifierProvider(
          create: (_) => PrevsemestersProvider()..loadIfNeeded(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrentSemesterProvider()..loadIfNeeded(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalenderProvider()..loadIfNeeded(),
        ),
        Provider(create: (_) => AttendanceRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              AttendanceCoursesProvider(context.read<AttendanceRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AttendanceStudentsProvider(context.read<AttendanceRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AttendanceSessionProvider(context.read<AttendanceRepository>()),
        ),
      ],
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  String? guardRoute(AuthProvider auth, String allowedRole) {
    if (!auth.isLoggedIn) return '/login';
    if (allowedRole == 'student' && !auth.isStudent) return '/unauthorized';
    if (allowedRole == 'instructor' && !auth.isInstructor) return '/unauthorized';
    if (allowedRole == 'admin' && !auth.isAdmin) return '/unauthorized';
    return null;
  }

  int _instructorIndex(String location) {
    if (location.startsWith('/instructor/files') ||
        location.startsWith('/instructor/course-details')) {
      return NavIndexes.courses;
    }
    if (location.startsWith('/instructor/attendance') ||
        location.startsWith('/instructor/attendance-report') ||
        location.startsWith('/instructor/schedule')) {
      return NavIndexes.schedule;
    }
    if (location.startsWith('/instructor/assignments') ||
        location.startsWith('/instructor/add-assignment') ||
        location.startsWith('/instructor/announcements')) {
      return NavIndexes.assignments;
    }
    if (location.startsWith('/instructor/profile') ||
        location.startsWith('/instructor/messages') ||
        location.startsWith('/instructor/reports')) {
      return NavIndexes.more;
    }
    return NavIndexes.home;
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    FlutterNativeSplash.remove();
    requestNotificationPermission();

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isOnLogin = state.matchedLocation == '/login';

        if (!isLoggedIn && !isOnLogin) return '/login';
        if (isLoggedIn && isOnLogin) {
          if (auth.isAdmin) return '/admin';
          if (auth.isInstructor) return '/instructor/home';
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // ── Student Routes ──────────────────────────────────
        GoRoute(path: '/instructor', redirect: (_, __) => '/instructor/home'),
        ShellRoute(
          redirect: (context, state) => guardRoute(auth, 'student'),
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/courses',
              name: 'courses',
              builder: (context, state) => const CoursePage(),
            ),
            GoRoute(
              path: '/current-semester',
              name: 'current-semester',
              builder: (context, state) => const CurrentSemesterPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: '/completed-courses',
              name: 'completed-courses',
              builder: (context, state) => const Prevsemesters(),
            ),
            GoRoute(
              path: '/courses-grades',
              name: 'courses-grades',
              builder: (context, state) => const GradesPage(),
            ),
            GoRoute(
              path: '/schedule',
              name: 'schedule',
              builder: (context, state) => const CalenderEvents(),
            ),
            GoRoute(
              path: '/technical-support',
              name: 'techincal-support',
              builder: (context, state) => const TechnicalSupportPage(),
            ),
            GoRoute(
              path: '/register-attendance',
              name: 'register-attendance',
              builder: (context, state) => const QRScannerPage(),
            ),
          ],
        ),

        // ── Instructor Routes ───────────────────────────────
        ShellRoute(
          redirect: (context, state) => guardRoute(auth, 'instructor'),
          builder: (context, state, child) => InstructorLayout(
            currentIndex: _instructorIndex(state.matchedLocation),
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/instructor/home',
              name: 'instructor-home',
              builder: (context, state) => const InstructorHomePage(),
            ),
            GoRoute(
              path: '/instructor/files',
              name: 'instructor-files',
              builder: (context, state) => const AddFilesPage(),
            ),
            GoRoute(
              path: '/instructor/course-details',
              name: 'instructor-course-details',
              builder: (context, state) => const CourseDetailsPage(),
            ),
            GoRoute(
              path: '/instructor/attendance',
              name: 'instructor-attendance',
              builder: (context, state) => const AttendancePage(),
            ),
            GoRoute(
              path: '/instructor/attendance-report',
              name: 'instructor-attendance-report',
              builder: (context, state) => const AttendanceReportPage(),
            ),
            GoRoute(
              path: '/instructor/assignments-list',
              name: 'instructor-assignments-list',
              builder: (context, state) => const AssignmentsPage(),
            ),
            GoRoute(
              path: '/instructor/add-assignment',
              name: 'instructor-add-assignment',
              builder: (context, state) => const AddAssignmentPage(),
            ),
            GoRoute(
              path: '/instructor/announcements',
              name: 'instructor-announcements',
              builder: (context, state) => const AnnouncementsPage(),
            ),
            GoRoute(
              path: '/instructor/messages',
              name: 'instructor-messages',
              builder: (context, state) => const MessagesPage(),
            ),
            GoRoute(
              path: '/instructor/reports',
              name: 'instructor-reports',
              builder: (context, state) => const ReportsAnalyticsPage(),
            ),
            GoRoute(
              path: '/instructor/schedule',
              name: 'instructor-schedule',
              builder: (context, state) => const SchedulePage(),
            ),
            GoRoute(
              path: '/instructor/profile',
              name: 'instructor-profile',
              builder: (context, state) => const InstructorProfilePage(),
            ),
          ],
        ),

        GoRoute(
          path: '/unauthorized',
          name: 'unauthorized',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text(
                'Unauthorized',
                style: TextStyle(fontSize: 20, color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UniDesk',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}