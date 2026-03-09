import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../language/langProvider.dart';
import '../mock_auth.dart';
import '../../../shared/widgets/langToggle.dart';
import '../../../core/constants/sizes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userID = TextEditingController();
  final password = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    userID.dispose();
    password.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final enteredUser = userID.text.trim();
    final enteredPass = password.text.trim();

    if (enteredUser.isEmpty || enteredPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your ID and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed(
      '/home',
      arguments: {
        'token': MockAuth.token,
        'userId': enteredUser,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: AppSizes.paddingTop,
              right: AppSizes.paddingHorizontal,
              child: const LangToggle(),
            ),
            Padding(
              padding: EdgeInsets.only(top: sw * 0.1),

              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/login_logo.png',
                      width: sw * 0.8,
                      height: sh * 0.5,
                    ),
                    SizedBox(
                      width: sw * 0.8,
                      child: Center(
                        child: TextField(
                          controller: userID,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: "Enter Your ID @aabu.edu.jo",
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600,
                            ),
                            suffixIcon: Icon(Icons.check),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: sw * 0.8,
                      child: Center(
                        child: TextField(
                          controller: password,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_open),
                            hintText: "Password",
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w600,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: sw * 0.8,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text("Forgot Password?"),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: sw * 0.6,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.grey)
                            : Text("Login"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
