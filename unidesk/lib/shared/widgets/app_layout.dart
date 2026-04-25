import 'package:flutter/material.dart';
import 'app_navbar.dart';
import 'app_footer.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showAppBar;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? const AppNavbar() : null,
      body: child,
      bottomNavigationBar: AppFooter(currentIndex: currentIndex),
    );
  }
}