import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../features/auth/authProvider.dart';
import '../../features/language/langProvider.dart';
 
// ─── Data model ───────────────────────────────────────────────────────────────
 
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.route,
  });
 
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  final String route;
}
 
// ─── Route maps ───────────────────────────────────────────────────────────────
 
const _studentItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    labelKey: 'home',
    route: '/',
  ),
  _NavItem(
    icon: Icons.book_outlined,
    activeIcon: Icons.book,
    labelKey: 'files',
    route: '/courses-files',
  ),
  _NavItem(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    labelKey: 'courses',
    route: '/courses',
  ),
  _NavItem(
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    labelKey: 'assignments',
    route: '/assignments',
  ),
  _NavItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    labelKey: 'profile',
    route: '/profile',
  ),
];
 
const _instructorItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    labelKey: 'home',
    route: '/instructor/home',
  ),
  _NavItem(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view,
    labelKey: 'courses',
    route: '/instructor/files',
  ),
  _NavItem(
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    labelKey: 'attendance',
    route: '/instructor/attendance',
  ),
  _NavItem(
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    labelKey: 'assignments',
    route: '/instructor/assignments-list',
  ),
  _NavItem(
    icon: Icons.menu,
    activeIcon: Icons.menu_open,
    labelKey: 'more',
    route: '/instructor/profile',
  ),
];
 
// ─── Widget ───────────────────────────────────────────────────────────────────
 
class AppFooter extends StatelessWidget {
  const AppFooter({
    super.key,
    required this.currentIndex,
    this.onTap,
  });
 
  final int currentIndex;
  final ValueChanged<int>? onTap;
 
  @override
  Widget build(BuildContext context) {
    final isStudent = context.select<AuthProvider, bool>(
      (auth) => auth.isStudent,
    );
 
    final items = isStudent ? _studentItems : _instructorItems;
    final safeIndex = currentIndex.clamp(0, items.length - 1);
 
    return SafeArea(
      top: false,                        // only pad the bottom
      child: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) => _handleTap(context, index, safeIndex, items),
        backgroundColor: AppColors.primaryBlue,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: Colors.black.withOpacity(0.7),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 26,
        items: items
            .map((item) => _buildNavItem(context, item))
            .toList(growable: false),
      ),
    );
  }
 
  // ─── Private helpers ────────────────────────────────────────────────────────
 
  void _handleTap(
    BuildContext context,
    int index,
    int safeIndex,
    List<_NavItem> items,
  ) {
    if (index == safeIndex) return;
 
    if (onTap != null) {
      onTap!(index);
      return;
    }
 
    context.go(items[index].route);
  }
 
  BottomNavigationBarItem _buildNavItem(
    BuildContext context,
    _NavItem item,
  ) {
    final label = context.select<LangProvider, String>(
      (lang) => lang.translate(item.labelKey),
    );
 
    return BottomNavigationBarItem(
      icon: Icon(item.icon),
      activeIcon: Icon(item.activeIcon),
      label: label,
    );
  }
}
 