import 'package:unidesk/features/auth/forgot_password/data/forgot_password_data_source.dart';
import 'package:unidesk/features/auth/forgot_password/models/forgot_password_result.dart';

abstract class ForgotPasswordRepository {
  Future<ForgotPasswordResult> sendResetEmail(String email);
}

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  const ForgotPasswordRepositoryImpl(this._dataSource);

  final ForgotPasswordDataSource _dataSource;

  @override
  Future<ForgotPasswordResult> sendResetEmail(String email) {
    return _dataSource.sendResetEmail(email);
  }
}

class ForgotPasswordRepositoryException implements Exception {
  const ForgotPasswordRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
