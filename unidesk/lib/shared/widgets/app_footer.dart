import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import '../../core/constants/constants.dart';
import '../../features/language/langProvider.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;

  const AppFooter({super.key, required this.currentIndex});

  void _onTabTapped(BuildContext context, int index, bool isStudent) {
    if (index == currentIndex) return;

    final routes = {
      NavIndexes.home: isStudent ? '/' : '/instructor/home',
      NavIndexes.courses: isStudent ? '/courses' : '/instructor/files',
      NavIndexes.schedule: isStudent ? '/schedule' : '/instructor/attendance',
      NavIndexes.profile: isStudent ? '/profile' : '/instructor/profile',
    };

    final route = routes[index];
    if (route == null) return;

    // Dismiss any open dialogs/bottom sheets before navigating
    if (context.canPop()) {
      context.pop();
    }

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
  final auth = Provider.of<AuthProvider>(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, index , auth.isStudent),
      backgroundColor: AppColors.primaryBlue,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.black,
      type: BottomNavigationBarType.fixed, // needed for 4+ items
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label:  lang.translate('home')
        ),
        BottomNavigationBarItem(
          icon: auth.isStudent ? const Icon(  Icons.book_outlined) : const Icon(Icons.folder_open_outlined),
          activeIcon: auth.isStudent ? const Icon(  Icons.book) : const Icon(Icons.folder_open),
          label:auth.isStudent ? lang.translate('courses') : lang.translate("files"),
        ),
        BottomNavigationBarItem(
          icon:auth.isStudent ? const Icon(Icons.calendar_today_outlined) : const Icon(Icons.check_circle_outlined),
          activeIcon: auth.isStudent ? const Icon(Icons.calendar_today) : const Icon(Icons.check_circle),
          label: auth.isStudent ? lang.translate('schedule') : lang.translate('attendance'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: lang.translate('profile'),
        ),
      ],
    );
  }
}
