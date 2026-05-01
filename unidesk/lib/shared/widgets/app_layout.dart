import 'package:flutter/material.dart';
import 'app_navbar.dart';
import 'app_footer.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showAppBar;
  final GlobalKey<NavigatorState>? navigatorKey;
  final ValueChanged<int>? onNavTap;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showAppBar = true,
    this.navigatorKey,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppNavbar(
              navigatorKey: navigatorKey,
            )
          : null,
      body: child,
      bottomNavigationBar: AppFooter(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}
