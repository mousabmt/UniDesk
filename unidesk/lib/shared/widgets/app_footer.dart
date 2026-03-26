import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../features/language/langProvider.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;

  const AppFooter({super.key, required this.currentIndex});

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    final routes = {
      NavIndexes.home: '/',
      NavIndexes.courses: '/courses',
      NavIndexes.schedule: '/schedule',
      NavIndexes.profile: '/profile',
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

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, index),
      backgroundColor: AppColors.primaryBlue,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.black,
      type: BottomNavigationBarType.fixed, // needed for 4+ items
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: lang.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book_outlined),
          activeIcon: const Icon(Icons.book),
          label: lang.translate('courses'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          activeIcon: const Icon(Icons.calendar_today),
          label: lang.translate('schedule'),
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
