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

    final studentRoutes = {
      0: '/',
      1: '/courses',
      2: '/schedule',
      3: '/profile',
    };

    final instructorRoutes = {
      0: '/instructor/home',
      1: '/instructor/files',         // ✅ كان instructor/courses - غلط
      2: '/instructor/attendance',
      3: '/instructor/assignments-list', // ✅ كان instructor/assignments - غلط
      4: '/instructor/profile',       // ✅ كان instructor/more - غلط
    };

    final routes = isStudent ? studentRoutes : instructorRoutes;
    final route = routes[index];
    if (route == null) return;

    // ✅ شيلنا الـ context.pop() - context.go() يكفي
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, index, auth.isStudent),
      backgroundColor: AppColors.primaryBlue,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.black,
      type: BottomNavigationBarType.fixed,
      items: auth.isStudent
          ? [
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
            ]
          : [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: lang.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_outlined),
                activeIcon: const Icon(Icons.grid_view),
                label: lang.translate('courses'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                activeIcon: const Icon(Icons.calendar_today),
                label: lang.translate('attendance'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.assignment_outlined),
                activeIcon: const Icon(Icons.assignment),
                label: lang.translate('assignments'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu),
                activeIcon: const Icon(Icons.menu_open),
                label: lang.translate('more'),
              ),
            ],
    );
  }
}