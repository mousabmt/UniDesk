import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/auth/forgot_password/data/forgot_password_data_source.dart';
import 'package:unidesk/features/auth/forgot_password/models/forgot_password_result.dart';

class ApiForgotPasswordDataSource implements ForgotPasswordDataSource {
  const ApiForgotPasswordDataSource();

  @override
  Future<ForgotPasswordResult> sendResetEmail(String email) async {
    try {
      final response = await StudentApi.forgotPassword(email);
      return ForgotPasswordResult.fromMap(response);
    } catch (error) {
      throw ForgotPasswordDataSourceException(error.toString());
    }
  }
}
