import 'package:flutter/material.dart';
import 'home_DR.dart';
import 'addfiles.dart';
import 'attendance.dart';
import "package:go_router/go_router.dart";
class InstructorLayout extends StatefulWidget {
  final Widget child;
  const InstructorLayout({required this.child, super.key});

  @override
  State<InstructorLayout> createState() => _InstructorLayoutState();
}

class _InstructorLayoutState extends State<InstructorLayout> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xff0bb4b1),
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          setState(() => currentIndex = i);
          switch (i) {
            case 0:
              context.go('/instructor/home');
              break;
            case 1:
              context.go('/instructor/files');
              break;
            case 2:
              context.go('/instructor/attendance');
              break;
            case 3:
              context.go('/instructor/profile');
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file), label: "Files"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fact_check), label: "Attendance"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class InstructorProfilePage extends StatelessWidget {
  const InstructorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0bb4b1),
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text(
          'Profile coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
