import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';

import '../../core/constants/constants.dart';
import '../../features/language/langProvider.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppFooter({super.key, required this.currentIndex, this.onTap});

  void _onTabTapped(BuildContext context, int index, bool isStudent) {
    if (index == currentIndex) return;

    final studentRoutes = {
      0: '/',
      1: '/courses-files',
      2: '/courses',
      3: '/assignments',
      4: '/profile',
    };

    final instructorRoutes = {
      0: '/instructor/home',
      1: '/instructor/files',
      2: '/instructor/attendance',
      3: '/instructor/assignments-list',
      4: '/instructor/profile',
    };

    final routes = isStudent ? studentRoutes : instructorRoutes;
    final route = routes[index];
    if (route == null) return;

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = context.select<AuthProvider, bool>(
      (auth) => auth.isStudent,
    );
    final homeLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('home'),
    );
    final filesLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('files'),
    );
    final coursesLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('courses'),
    );
    final assignmentsLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('assignments'),
    );
    final attendanceLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('attendance'),
    );
    final profileLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('profile'),
    );
    final moreLabel = context.select<LangProvider, String>(
      (lang) => lang.translate('more'),
    );
    final items = isStudent
        ? [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: homeLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book_outlined),
              activeIcon: const Icon(Icons.book),
              label: filesLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: coursesLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment),
              label: assignmentsLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: profileLabel,
            ),
          ]
        : [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: homeLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view),
              label: coursesLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: attendanceLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment),
              label: assignmentsLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu),
              activeIcon: const Icon(Icons.menu_open),
              label: moreLabel,
            ),
          ];
    final safeIndex = currentIndex >= 0 && currentIndex < items.length
        ? currentIndex
        : 0;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: (index) {
        if (index == safeIndex) return;
        if (onTap != null) {
          onTap!(index);
          return;
        }
        _onTabTapped(context, index, isStudent);
      },
      backgroundColor: AppColors.primaryBlue,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.black,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}
