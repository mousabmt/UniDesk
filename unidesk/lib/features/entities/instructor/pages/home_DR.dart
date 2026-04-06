import 'package:flutter/material.dart';

class InstructorHomePage extends StatelessWidget {
  const InstructorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3f7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------- TOP HEADER ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff0bb4b1),
                      Color(0xff4cc7c3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- WELCOME ----------
              const Text(
                "Welcome back, Dr. Ahmad",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Upload and manage your course files.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 18),

              // ---------- DATE PICKER CARD ----------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      "Tuesday, May 14, 2024",
                      style: TextStyle(fontSize: 15),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------- Today's Lectures ----------
              const Text(
                "Today's Lectures",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              LectureCard(
                course: "CS301 - Data Structures",
                time: "10:00 AM - 11:30 AM",
              ),

              const SizedBox(height: 12),

              LectureCard(
                course: "STAT210 - Statistics II",
                time: "1:00 PM - 2:30 PM",
              ),

              const SizedBox(height: 25),

              // ---------- Quick Actions ----------
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  QuickAction(icon: Icons.upload_file, label: "Upload Files"),
                  QuickAction(icon: Icons.fact_check, label: "Take Attendance"),
                  QuickAction(icon: Icons.bar_chart, label: "View Reports"),
                ],
              ),

              const SizedBox(height: 30),

              // ---------- My Courses ----------
              const Text(
                "My Courses",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CourseCard(title: "CS301", subtitle: "Data Structures"),
                  CourseCard(title: "STAT210", subtitle: "Statistics II"),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= WIDGETS =======================

// -------- Lecture Card --------
class LectureCard extends StatelessWidget {
  final String course;
  final String time;

  const LectureCard({super.key, required this.course, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff0bb4b1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // icon box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffd2f4f2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_open,
              color: Color(0xff0bb4b1),
            ),
          ),
        ],
      ),
    );
  }
}

// -------- Quick Action Button --------
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickAction({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Color(0xff0bb4b1)),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

// -------- Course Card --------
class CourseCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const CourseCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xff0bb4b1),
              )),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}