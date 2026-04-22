import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../language/langProvider.dart';
import '../../../shared/widgets/langToggle.dart';
import '../authProvider.dart';
import '../../../core/constants/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userID = TextEditingController();
  final password = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    userID.dispose();
    password.dispose();
    super.dispose();
  }
void _handleLogin() async {
  final lang = context.read<LangProvider>();
  final enteredUser = userID.text.trim();
  final enteredPass = password.text.trim();

  if (enteredUser.isEmpty || enteredPass.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(lang.translate('please_enter_id_password'))),
    );
    return;
  }

  final success =
      await context.read<AuthProvider>().login(enteredUser, enteredPass);

  if (!mounted) return;

  if (!success) {
    final error = context.read<AuthProvider>().errorMessage 
        ?? lang.translate('invalid_token');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Scaffold(
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
                          keyboardType: TextInputType.emailAddress,
                          controller: userID,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: lang.translate('enter_id'),
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
                            hintText: lang.translate('password'),
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
                          child: Text(lang.translate('forgot_password')),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: sw * 0.6,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleLogin,
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
                        child: auth.isLoading
                            ? SizedBox(height: 20,width: 20,child: CircularProgressIndicator(color: Colors.grey))
                            : Text(lang.translate('login')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );  
      }
}
