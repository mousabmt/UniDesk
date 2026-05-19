import 'package:flutter/material.dart';
import 'package:unidesk/features/auth/forgot_password/data/forgot_password_repository.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  ForgotPasswordProvider(this._repository);

  final ForgotPasswordRepository _repository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> submit(String email) async {
    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    _isSuccess = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.sendResetEmail(email.trim());
      _isSuccess = result.success;
      if (result.success) {
        _successMessage = result.message;
      } else {
        _errorMessage = result.message;
      }
      return result.success;
    } catch (error) {
      _isSuccess = false;
      _errorMessage = 'Unable to send reset instructions. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
