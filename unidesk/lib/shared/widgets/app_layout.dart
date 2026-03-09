import 'package:flutter/material.dart';
import 'app_navbar.dart';
import 'app_footer.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex; // which tab is active

  const AppLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      body: child,
      bottomNavigationBar: AppFooter(currentIndex: currentIndex),
    );
  }
}