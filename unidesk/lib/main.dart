import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/auth/pages/login.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/instructor_assignments_repository.dart';
import 'package:unidesk/features/entities/instructor/assignments/data/mock_instructor_assignments_data_source.dart';
import 'package:unidesk/features/entities/instructor/assignments/providers/instructor_assignments_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/data/attendance_repository.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_session_provider.dart';
import 'package:unidesk/features/entities/instructor/attendance/providers/attendance_students_provider.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/api_instructor_courses_data_source.dart';
import 'package:unidesk/features/entities/instructor/course_management/data/instructor_courses_repository.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/pages/Announcements.dart';
import 'package:unidesk/features/entities/instructor/pages/Attendance_Report.dart';
import 'package:unidesk/features/entities/instructor/pages/Messages.dart';
import 'package:unidesk/features/entities/instructor/pages/Profile.dart';
import 'package:unidesk/features/entities/instructor/pages/Reports_Analytics.dart';
import 'package:unidesk/features/entities/instructor/pages/Schedule.dart';
import 'package:unidesk/features/entities/instructor/pages/add_assignment.dart';
import 'package:unidesk/features/entities/instructor/pages/addfiles.dart';
import 'package:unidesk/features/entities/instructor/pages/assignments_page.dart';
import 'package:unidesk/features/entities/instructor/pages/attendance_page.dart';
import 'package:unidesk/features/entities/instructor/pages/course_details.dart';
import 'package:unidesk/features/entities/instructor/pages/home.dart';
import 'package:unidesk/features/entities/instructor/pages/instructorLayout.dart';
import 'package:unidesk/features/entities/student/pages/QRScannerRegister.dart';
import 'package:unidesk/features/entities/student/pages/calenderEvents.dart';
import 'package:unidesk/features/entities/student/pages/courses.dart';
import 'package:unidesk/features/entities/student/pages/currentSemesterPage.dart';
import 'package:unidesk/features/entities/student/pages/gradesPage.dart';
import 'package:unidesk/features/entities/student/pages/home.dart';
import 'package:unidesk/features/entities/student/pages/prevSemesters.dart';
import 'package:unidesk/features/entities/student/pages/profile_page.dart'
    as student_profile;
import 'package:unidesk/features/entities/student/pages/techinalSupportPage.dart';
import 'package:unidesk/features/entities/student/providers_std/CalenderProvider.dart';
import 'package:unidesk/features/entities/student/providers_std/annouc_provider.dart';
import 'package:unidesk/features/entities/student/providers_std/course_provider.dart';
import 'package:unidesk/features/entities/student/providers_std/currentSem_provider.dart';
import 'package:unidesk/features/entities/student/providers_std/prevSemesters_provider.dart';
import 'package:unidesk/features/entities/student/providers_std/profile_provider.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';

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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => AnnoucProvider()),
        ChangeNotifierProvider(create: (_) => PrevsemestersProvider()),
        ChangeNotifierProvider(create: (_) => CurrentSemesterProvider()),
        ChangeNotifierProvider(create: (_) => CalenderProvider()),
        Provider(create: (_) => AttendanceRepository()),
        Provider<InstructorCoursesRepository>(
          create: (_) => const InstructorCoursesRepositoryImpl(
            ApiInstructorCoursesDataSource(),
          ),
        ),
        Provider<InstructorAssignmentsRepository>(
          create: (_) => const InstructorAssignmentsRepositoryImpl(
            MockInstructorAssignmentsDataSource(),
          ),
        ),
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
        ChangeNotifierProvider(
          create: (context) => InstructorCoursesProvider(
            context.read<InstructorCoursesRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => InstructorAssignmentsProvider(
            context.read<InstructorAssignmentsRepository>(),
            context.read<InstructorCoursesRepository>(),
          ),
        ),
      ],
      builder: (_, _) => const MyApp(),
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

  String? _guardRoute(AuthProvider auth, String allowedRole) {
    if (!auth.isLoggedIn) {
      return '/login';
    }
    if (allowedRole == 'student' && !auth.isStudent) {
      return '/unauthorized';
    }
    if (allowedRole == 'instructor' && !auth.isInstructor) {
      return '/unauthorized';
    }
    if (allowedRole == 'admin' && !auth.isAdmin) {
      return '/unauthorized';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    FlutterNativeSplash.remove();
    unawaited(requestNotificationPermission());

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isOnLogin = state.matchedLocation == '/login';

        if (!isLoggedIn && !isOnLogin) {
          return '/login';
        }
        if (isLoggedIn && isOnLogin) {
          if (auth.isInstructor) {
            return '/instructor/home';
          }
          if (auth.isStudent) {
            return '/';
          }
          return '/unauthorized';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(path: '/instructor', redirect: (_, _) => '/instructor/home'),
        StatefulShellRoute.indexedStack(
          redirect: (context, state) => _guardRoute(auth, 'student'),
          builder: (context, state, navigationShell) =>
              _StudentShellLayout(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'home',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/courses',
                  name: 'courses',
                  builder: (context, state) => const CoursePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/schedule',
                  name: 'schedule',
                  builder: (context, state) => const CalenderEvents(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) =>
                      const student_profile.ProfilePage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          redirect: (context, state) => _guardRoute(auth, 'instructor'),
          builder: (context, state, navigationShell) => InstructorLayout(
            currentIndex: navigationShell.currentIndex,
            onNavTap: (index) =>
                navigationShell.goBranch(index, initialLocation: index == 3),
            child: navigationShell,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/instructor/home',
                  name: 'instructor-home',
                  builder: (context, state) => const InstructorHomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/instructor/files',
                  name: 'instructor-files',
                  builder: (context, state) => AddFilesPage(
                    initialCourseId: state.uri.queryParameters['courseId'],
                  ),
                ),
                GoRoute(
                  path: '/instructor/course-details',
                  name: 'instructor-course-details',
                  builder: (context, state) => CourseDetailsPage(
                    initialCourseId: state.uri.queryParameters['courseId'],
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
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
                  path: '/instructor/schedule',
                  name: 'instructor-schedule',
                  builder: (context, state) => const SchedulePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/instructor/assignments-list',
                  name: 'instructor-assignments-list',
                  builder: (context, state) => AssignmentsPage(
                    initialCourseId: state.uri.queryParameters['courseId'],
                    lockCourseSelection:
                        state.uri.queryParameters['lockCourse'] == '1',
                    successMessage: state.extra as String?,
                  ),
                ),
                GoRoute(
                  path: '/instructor/add-assignment',
                  name: 'instructor-add-assignment',
                  builder: (context, state) => AddAssignmentPage(
                    initialCourseId: state.uri.queryParameters['courseId'],
                    lockCourseSelection:
                        state.uri.queryParameters['lockCourse'] == '1',
                  ),
                ),
                GoRoute(
                  path: '/instructor/announcements',
                  name: 'instructor-announcements',
                  builder: (context, state) => const AnnouncementsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/instructor/profile',
                  name: 'instructor-profile',
                  builder: (context, state) => const ProfilePage(),
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
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/current-semester',
          name: 'current-semester',
          redirect: (context, state) => _guardRoute(auth, 'student'),
          builder: (context, state) => const CurrentSemesterPage(),
        ),
        GoRoute(
          path: '/completed-courses',
          name: 'completed-courses',
          redirect: (context, state) => _guardRoute(auth, 'student'),
          builder: (context, state) => const Prevsemesters(),
        ),
        GoRoute(
          path: '/courses-grades',
          name: 'courses-grades',
          redirect: (context, state) => _guardRoute(auth, 'student'),
          builder: (context, state) => const GradesPage(),
        ),
        GoRoute(
          path: '/technical-support',
          name: 'technical-support',
          redirect: (context, state) => _guardRoute(auth, 'student'),
          builder: (context, state) => const TechnicalSupportPage(),
        ),
        GoRoute(
          path: '/register-attendance',
          name: 'register-attendance',
          redirect: (context, state) => _guardRoute(auth, 'student'),
          builder: (context, state) => const QRScannerPage(),
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

class _StudentShellLayout extends StatelessWidget {
  const _StudentShellLayout({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: navigationShell.currentIndex,
      onNavTap: (index) => navigationShell.goBranch(index),
      child: navigationShell,
    );
  }
}
