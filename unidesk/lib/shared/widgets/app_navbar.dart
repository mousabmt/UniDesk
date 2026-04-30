import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../features/auth/authProvider.dart';
import '../../features/language/langProvider.dart';
import 'langToggle.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const AppNavbar({
    super.key,
    this.navigatorKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final navigator = navigatorKey?.currentState;
    final canGoBack = navigator?.canPop() ?? context.canPop();

    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,

      leading: canGoBack
          ? IconButton(
              icon: Icon(
                lang.isArabic ? Icons.arrow_forward : Icons.arrow_back,
                color: AppColors.black,
              ),
              onPressed: () {
                if (navigator?.canPop() ?? false) {
                  navigator!.pop();
                  return;
                }
                if (context.canPop()) {
                  context.pop();
                }
              },
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: const LangToggle(),
            ),

      title: Text(
        'UniDesk',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontMedium,
        ),
      ),
      centerTitle: true,

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.black,
          onPressed: () {},
        ),

        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: AppColors.black),
          onSelected: (value) {
            switch (value) {
              case 'home':
                if (auth.isStudent) {
                  context.go('/');
                } else {
                  context.go('/instructor/home');
                }
                break;
              case 'courses':
                if (auth.isStudent) {
                  context.go('/courses');
                } else {
                  context.go('/instructor/files'); // ✅
                }
                break;
              case 'schedule':
                if (auth.isStudent) {
                  context.go('/schedule');
                } else {
                  context.go('/instructor/attendance'); // ✅
                }
                break;
              case 'profile':
                if (auth.isStudent) {
                  context.go('/profile');
                } else {
                  context.go('/instructor/profile'); // ✅
                }
                break;
              case 'logout':
                context.read<AuthProvider>().logout();
                context.go('/login');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'home', // ✅ ثابت
              child: Text(lang.translate('home')),
            ),
            PopupMenuItem(
              value: 'courses', // ✅ ثابت - الـ onSelected يفرق بين student/instructor
              child: auth.isStudent
                  ? Text(lang.translate('current_courses'))
                  : Text(lang.translate('files')),
            ),
            PopupMenuItem(
              value: 'schedule', // ✅ ثابت
              child: auth.isStudent
                  ? Text(lang.translate('schedule'))
                  : Text(lang.translate('attendance')),
            ),
            PopupMenuItem(
              value: 'profile', // ✅ ثابت
              child: Text(lang.translate('profile')),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text(lang.translate('logout')),
            ),
          ],
        ),
      ],
    );
  }
}
