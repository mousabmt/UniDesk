import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/mock_auth.dart';
import 'package:unidesk/features/auth/pages/login.dart';
import 'package:unidesk/features/home/pages/home.dart';

import './features/language/langProvider.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LangProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MaterialApp(
      title: 'UniDesk',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final token = args?['token'] as String?;
          final userId = (args?['userId'] as String?) ?? 'Student';

          if (!MockAuth.isValidToken(token)) {
            return const LoginPage();
          }

          return HomePage(token: token!, userId: userId);
        },
      },
    );
  }
}
