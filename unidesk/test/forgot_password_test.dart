import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/forgot_password/data/forgot_password_repository.dart';
import 'package:unidesk/features/auth/forgot_password/models/forgot_password_result.dart';
import 'package:unidesk/features/auth/forgot_password/pages/forgot_password_page.dart';
import 'package:unidesk/features/auth/forgot_password/providers/forgot_password_provider.dart';
import 'package:unidesk/features/language/langProvider.dart';

void main() {
  group('ForgotPasswordProvider', () {
    test('successful response sets success state', () async {
      final repository = _FakeForgotPasswordRepository(
        result: const ForgotPasswordResult(
          success: true,
          message: 'Reset email sent.',
        ),
      );
      final provider = ForgotPasswordProvider(repository);

      final success = await provider.submit('student@aabu.edu.jo');

      expect(success, isTrue);
      expect(provider.isSuccess, isTrue);
      expect(provider.successMessage, 'Reset email sent.');
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
      expect(repository.lastEmail, 'student@aabu.edu.jo');
    });

    test('failed response exposes error and resets loading', () async {
      final provider = ForgotPasswordProvider(
        _FakeForgotPasswordRepository(
          result: const ForgotPasswordResult(
            success: false,
            message: 'Email was not found.',
          ),
        ),
      );

      final success = await provider.submit('missing@aabu.edu.jo');

      expect(success, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.errorMessage, 'Email was not found.');
      expect(provider.successMessage, isNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('ForgotPasswordPage', () {
    testWidgets('renders form actions', (tester) async {
      await tester.pumpWidget(
        _ForgotPasswordTestApp(
          repository: _FakeForgotPasswordRepository(
            result: const ForgotPasswordResult(
              success: true,
              message: 'Reset email sent.',
            ),
          ),
        ),
      );

      expect(find.text('Reset your password'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('forgot-password-email-field')),
        findsOneWidget,
      );
      expect(find.text('Send reset link'), findsOneWidget);
      expect(find.text('Back to login'), findsOneWidget);
    });

    testWidgets('rejects invalid email before submitting', (tester) async {
      final repository = _FakeForgotPasswordRepository(
        result: const ForgotPasswordResult(
          success: true,
          message: 'Reset email sent.',
        ),
      );

      await tester.pumpWidget(_ForgotPasswordTestApp(repository: repository));
      await tester.enterText(
        find.byKey(const ValueKey('forgot-password-email-field')),
        'not-an-email',
      );
      await tester.tap(
        find.byKey(const ValueKey('forgot-password-submit-button')),
      );
      await tester.pump();

      expect(
        find.text('Please enter a valid university email.'),
        findsOneWidget,
      );
      expect(repository.lastEmail, isNull);
    });

    testWidgets('submitting valid email shows success message', (tester) async {
      final repository = _FakeForgotPasswordRepository(
        result: const ForgotPasswordResult(
          success: true,
          message: 'Check your inbox for reset instructions.',
        ),
      );

      await tester.pumpWidget(_ForgotPasswordTestApp(repository: repository));
      await tester.enterText(
        find.byKey(const ValueKey('forgot-password-email-field')),
        'abdulah242r@gmail.com',
      );
      await tester.tap(
        find.byKey(const ValueKey('forgot-password-submit-button')),
      );
      await tester.pumpAndSettle();

      expect(repository.lastEmail, 'abdulah242r@gmail.com');
      expect(
        find.text('Check your inbox for reset instructions.'),
        findsOneWidget,
      );
    });
  });
}

class _ForgotPasswordTestApp extends StatelessWidget {
  const _ForgotPasswordTestApp({required this.repository});

  final ForgotPasswordRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LangProvider()),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordProvider(repository),
        ),
      ],
      child: const MaterialApp(home: ForgotPasswordPage()),
    );
  }
}

class _FakeForgotPasswordRepository implements ForgotPasswordRepository {
  _FakeForgotPasswordRepository({required this.result});

  final ForgotPasswordResult result;
  String? lastEmail;

  @override
  Future<ForgotPasswordResult> sendResetEmail(String email) async {
    lastEmail = email;
    return result;
  }
}
