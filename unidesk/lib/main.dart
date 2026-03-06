import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/pages/login.dart';
import './features/language/langProvider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
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
  FlutterNativeSplash.remove(); // ← add this
    return MaterialApp(
      
      title: 'UniDesk',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
      },
    );
  }
}
