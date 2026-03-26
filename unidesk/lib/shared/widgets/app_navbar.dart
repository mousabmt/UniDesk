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
                context.go('/');
                break;
              case 'courses':
                context.go('/courses');
                break;
              case 'schedule':
                context.go('/schedule');
                break;
              case 'profile':
                context.go('/profile');
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
              value: 'courses',
              child: Text(lang.translate('current_courses')),
            ),
            PopupMenuItem(
              value: 'schedule',
              child: Text(lang.translate('schedule')),
            ),
            PopupMenuItem(
              value: "profile",
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
