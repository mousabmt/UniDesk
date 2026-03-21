import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/pages/login.dart';
import 'package:unidesk/features/home/student/pages/gradesPage.dart';
import 'package:unidesk/features/home/student/pages/home.dart';
import 'package:unidesk/features/home/student/pages/profile_page.dart';
import 'package:unidesk/features/home/student/providers_std/profile_provider.dart';
import 'package:unidesk/features/schedule/pages/schedule_page.dart';
import 'features/home/student/pages/courses.dart';
import './features/language/langProvider.dart';
import './features/auth/authProvider.dart';
import './features/home/student/providers_std/course_provider.dart';
import './features/home/student/providers_std/annouc_provider.dart';
import 'features/home/student/providers_std/prevSemesters_provider.dart';
import 'features/home/student/pages/prevSemesters.dart';

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

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.userId != null && auth.isValidToken;
        final isOnLogin = state.matchedLocation == '/login';

        if (!isLoggedIn && !isOnLogin) return '/login';
        if (isLoggedIn && isOnLogin) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/courses',
          name: 'courses',
          builder: (context, state) => const CoursePage(),
        ),
        GoRoute(
          path: '/schedule',
          name: 'schedule',
          builder: (context, state) => const SchedulePage(),
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
