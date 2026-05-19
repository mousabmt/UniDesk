import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/auth/forgot_password/providers/forgot_password_provider.dart';
import 'package:unidesk/shared/widgets/langToggle.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _looksLikeEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final provider = context.read<ForgotPasswordProvider>();
    final success = await provider.submit(_emailController.text);

    if (!mounted || success) {
      return;
    }

    final error =
        provider.errorMessage ??
        'Unable to send reset instructions. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
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
                          isCompact ? sw * 0.72 : sw * 0.48,
                        );
                        final maxLogoHeight = isCompact
                            ? math.min(sh * 0.28, 220.0)
                            : math.min(sh * 0.38, 320.0);
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
                                child: Consumer<ForgotPasswordProvider>(
                                  builder: (context, provider, _) {
                                    return AutofillGroup(
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
                                                filterQuality:
                                                    FilterQuality.low,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: isCompact ? 18 : 24),
                                          _ForgotPasswordPanel(
                                            formKey: _formKey,
                                            emailController: _emailController,
                                            isLoading: provider.isLoading,
                                            isSuccess: provider.isSuccess,
                                            successMessage:
                                                provider.successMessage,
                                            validateEmail: (value) {
                                              final email = value?.trim() ?? '';
                                              if (email.isEmpty) {
                                                return 'Please enter your university email.';
                                              }
                                              if (!_looksLikeEmail(email)) {
                                                return 'Please enter a valid university email.';
                                              }
                                              return null;
                                            },
                                            onSubmit: provider.isLoading
                                                ? null
                                                : _submit,
                                            onBackToLogin: () {
                                              provider.reset();
                                              context.go('/login');
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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

class _ForgotPasswordPanel extends StatelessWidget {
  const _ForgotPasswordPanel({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.isSuccess,
    required this.successMessage,
    required this.validateEmail,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final bool isSuccess;
  final String? successMessage;
  final String? Function(String?) validateEmail;
  final VoidCallback? onSubmit;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset your password',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.black,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                ) ??
                const TextStyle(
                  color: AppColors.black,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter your university email and we will send you reset instructions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff334155),
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          if (isSuccess)
            _SuccessNotice(message: successMessage)
          else ...[
            TextFormField(
              key: const ValueKey('forgot-password-email-field'),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: validateEmail,
              onFieldSubmitted: (_) => onSubmit?.call(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail_outline),
                hintText: 'Enter your university email',
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                key: const ValueKey('forgot-password-submit-button'),
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : const Text(
                        'Send reset link',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            key: const ValueKey('forgot-password-back-button'),
            onPressed: onBackToLogin,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to login'),
          ),
        ],
      ),
    );
  }
}

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffecfdf5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff86efac)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_read_outlined, color: Color(0xff15803d)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Password reset instructions sent.',
              style: const TextStyle(
                color: Color(0xff14532d),
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
