import 'package:unidesk/features/auth/forgot_password/models/forgot_password_result.dart';

abstract class ForgotPasswordDataSource {
  Future<ForgotPasswordResult> sendResetEmail(String email);
}

class ForgotPasswordDataSourceException implements Exception {
  const ForgotPasswordDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
