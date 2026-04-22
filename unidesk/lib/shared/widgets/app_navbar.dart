import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../features/language/langProvider.dart';
import '../../features/auth/authProvider.dart';
import 'langToggle.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final canGoBack = context.canPop(); //checks if there's a page behind

    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,

      // Back button
      leading: canGoBack
          ? IconButton(
              icon: Icon(
                lang.isArabic ? Icons.arrow_forward : Icons.arrow_back,
                color: AppColors.black,
              ),
              onPressed: () => context.pop(), //go back
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: const LangToggle(),
            ),

      // App name
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

        // hamburger menu for 3 features (Current courses, techincal support, electronic payment)
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: AppColors.black),
          onSelected: (value) {
            switch (value) {
              case 'home':
                if(auth.isStudent){
                  context.go('/');
                } else {
                  context.go('/instructor/home');
                }
                break;
              case 'courses':
                if(auth.isStudent){
                  context.go('/courses');
                } else {
                  context.go('/instructor/files');
                }
                break;
              case 'schedule':
                if(auth.isStudent){
                  context.go('/schedule');
                } else {
                  context.go('/instructor/attendance');
                }
                break;
              case 'profile':
                if(auth.isStudent){
                  context.go('/profile');
                } else {
                  context.go('/instructor/profile');
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
             value: "home",
             child: Text(lang.translate("home"))
             ),
            PopupMenuItem(
              value: auth.isStudent ? 'courses' : 'instructor_courses',
              child: auth.isStudent ? Text(lang.translate('current_courses')) : Text(lang.translate('files')),
            ),
            PopupMenuItem(
              value: auth.isStudent ? 'schedule' : 'instructor_schedule',
              child: auth.isStudent ? Text(lang.translate('schedule')) : Text(lang.translate('attendance')),
            ),
            PopupMenuItem(
              value: auth.isStudent ? "profile" : "instructor_profile",
              child: Text(lang.translate("profile")),
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
