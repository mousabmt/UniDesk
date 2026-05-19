import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../shared/widgets/langToggle.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../language/langProvider.dart';
import '../authProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userID = TextEditingController();
  final password = TextEditingController();
  bool _isPasswordVisible = false;

  bool _looksLikeEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

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

    if (!_looksLikeEmail(enteredUser)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid university email.')),
      );
      return;
    }

    final success = await context.read<AuthProvider>().login(
      enteredUser,
      enteredPass,
    );

    if (!mounted) return;

    if (success) {
      final auth = context.read<AuthProvider>();
      if (auth.isInstructor) {
        context.go('/instructor/home');
        return;
      }
      if (auth.isStudent) {
        context.go('/');
        return;
      }
      context.go('/unauthorized');
      return;
    }

    if (!success) {
      final error =
          context.read<AuthProvider>().errorMessage ??
          lang.translate('invalid_token');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final mediaQuery = MediaQuery.of(context);
    final sw = mediaQuery.size.width;
    final sh = mediaQuery.size.height;
    final isCompact = ResponsiveLayout.isCompact(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: Image.asset(
                  'assets/images/login_bg.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: math.max(12, AppSizes.paddingTop - 24),
                    right: AppSizes.paddingHorizontal,
                    child: const LangToggle(),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontalPadding = isCompact
                            ? sw * 0.1
                            : sw * 0.18;
                        final contentWidth = math.min(
                          isCompact ? 420.0 : 520.0,
                          constraints.maxWidth,
                        );
                        final logoWidth = math.min(
                          contentWidth,
                          isCompact ? sw * 0.8 : sw * 0.55,
                        );
                        final maxLogoHeight = isCompact
                            ? math.min(sh * 0.34, 260.0)
                            : math.min(sh * 0.5, 420.0);
                        final topSpacing = isCompact ? sw * 0.08 : sw * 0.05;

                        return SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            topSpacing,
                            horizontalPadding,
                            24,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - topSpacing,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: contentWidth,
                                child: AutofillGroup(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      RepaintBoundary(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: logoWidth,
                                            maxHeight: maxLogoHeight,
                                          ),
                                          child: Image.asset(
                                            'assets/images/login_logo.png',
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.low,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isCompact ? 20 : 28),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: userID,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.username,
                                          ],
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                              Icons.person_outline,
                                            ),
                                            hintText: lang.translate(
                                              'enter_id',
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'PlusJakartaSans',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextField(
                                          controller: password,
                                          obscureText: !_isPasswordVisible,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          onSubmitted: (_) {
                                            if (!context
                                                .read<AuthProvider>()
                                                .isLoading) {
                                              _handleLogin();
                                            }
                                          },
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                              Icons.lock_open,
                                            ),
                                            hintText: lang.translate(
                                              'password',
                                            ),
                                            hintStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'PlusJakartaSans',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible =
                                                      !_isPasswordVisible;
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
                                      SizedBox(
                                        width: double.infinity,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              context.go('/forgot-password');
                                            },
                                            child: Text(
                                              lang.translate('forgot_password'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            contentWidth *
                                            (isCompact ? 0.75 : 0.6),
                                        child: Selector<AuthProvider, bool>(
                                          selector: (_, auth) => auth.isLoading,
                                          builder: (context, isLoading, _) =>
                                              ElevatedButton(
                                                onPressed: isLoading
                                                    ? null
                                                    : _handleLogin,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryBlue,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                child: isLoading
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      )
                                                    : Text(
                                                        lang.translate('login'),
                                                      ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
