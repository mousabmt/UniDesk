import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/mock_auth.dart';
import '../../../features/language/langProvider.dart';
import '../../../shared/widgets/langToggle.dart';

class HomePage extends StatelessWidget {
  final String token;
  final String userId;

  const HomePage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final valid = MockAuth.isValidToken(token);

    return Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: const [LangToggle()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  valid ? Icons.verified_user : Icons.lock_outline,
                  size: 64,
                  color: valid ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  valid ? 'Welcome to UniDesk' : 'Invalid token',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  valid ? 'Logged in as: $userId' : 'Please login again.',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  child: Text(valid ? 'Logout' : 'Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
