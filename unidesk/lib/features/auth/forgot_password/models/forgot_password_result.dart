class ForgotPasswordResult {
  const ForgotPasswordResult({required this.success, required this.message});

  final bool success;
  final String message;

  factory ForgotPasswordResult.fromMap(Map<String, dynamic> map) {
    final success = map['success'] == true;
    final message = map['message']?.toString();

    return ForgotPasswordResult(
      success: success,
      message: message != null && message.isNotEmpty
          ? message
          : success
          ? 'Password reset instructions sent.'
          : 'Unable to send reset instructions.',
    );
  }
}
