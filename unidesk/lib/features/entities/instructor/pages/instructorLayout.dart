import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_layout.dart';

class InstructorLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final GlobalKey<NavigatorState>? navigatorKey;
  final ValueChanged<int>? onNavTap;

  const InstructorLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    this.navigatorKey,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: currentIndex,
      child: child,
      navigatorKey: navigatorKey,
      onNavTap: onNavTap,
    );
  }
}
