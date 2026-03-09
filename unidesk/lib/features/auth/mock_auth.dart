class MockAuth {
  static const String token = 'mock-token-123';

  static bool isValidToken(String? value) => value == token;
}
