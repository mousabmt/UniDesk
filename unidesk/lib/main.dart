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
import 'package:unidesk/features/entities/instructor/pages/attendance.dart';

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
      ],
      child: const MyApp(),
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

  // helper function
  String? guardRoute(AuthProvider auth, String allowedRole) {
    if (!auth.isLoggedIn) return '/login';
    if (allowedRole == 'student' && !auth.isStudent) return '/unauthorized';
    if (allowedRole == 'instructor' && !auth.isInstructor) return '/unauthorized';
    if (allowedRole == 'admin' && !auth.isAdmin) return '/unauthorized';
    return null;
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

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
          return '/'; // else go to student
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/instructor',
          redirect: (_, __) => '/instructor/home',
        ),
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
          ],
        ),
        ShellRoute(
          redirect: (context, state) => guardRoute(auth, 'instructor'),
          builder: (context, state, child) => InstructorLayout(child: child),
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
              path: '/instructor/attendance',
              name: 'instructor-attendance',
              builder: (context, state) => const AttendancePage(),
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
    FlutterNativeSplash.remove();

    return MaterialApp.router(
      title: 'UniDesk',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
