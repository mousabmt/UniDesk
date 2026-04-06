import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/add_files_page.dart';
import 'pages/attendance_page.dart';

class InstructorLayout extends StatefulWidget {
  const InstructorLayout({super.key});

  @override
  State<InstructorLayout> createState() => _InstructorLayoutState();
}

class _InstructorLayoutState extends State<InstructorLayout> {
  int currentIndex = 0;

  final pages = const [
    InstructorHomePage(),
    AddFilesPage(),
    AttendancePage(),
    InstructorProfilePage(), // لو بدك نعملها
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xff0bb4b1),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => currentIndex = i),

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