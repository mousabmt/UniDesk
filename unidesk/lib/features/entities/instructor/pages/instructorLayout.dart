import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_layout.dart';

class InstructorLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const InstructorLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: currentIndex,
      child: child,
    );
  }
}

class InstructorProfilePage extends StatelessWidget {
  const InstructorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Profile coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
