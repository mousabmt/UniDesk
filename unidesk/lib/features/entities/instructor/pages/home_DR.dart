import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InstructorHomePage extends StatelessWidget {
  const InstructorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4f8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── WELCOME CARD ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0, top: 0, bottom: 0,
                        child: SizedBox(width: 160, child: CustomPaint(painter: _WavePainter())),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: const Color(0xffe0f7f6),
                              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=68"),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("Welcome back,", style: TextStyle(fontSize: 16, color: Colors.black87)),
                                Text("Dr. Ahmad 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("Tuesday, May 14, 2024", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Overview
                  const Text("Today's Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: OverviewCard(value: "2", label: "Lectures Today", valueColor: Colors.orange)),
                      const SizedBox(width: 10),
                      Expanded(child: OverviewCard(value: "85%", label: "Today Attendance", valueColor: Color(0xff0bb4b1))),
                      const SizedBox(width: 10),
                      Expanded(child: OverviewCard(value: "24", label: "Students Absent", valueColor: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Next Lecture
                  const Text("Next Lecture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("CS301 – Data Structures",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0bb4b1))),
                              SizedBox(height: 6),
                              Text("10:00 AM - 11:30 AM", style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 4),
                              Text("Building B, Room 2203", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xffd2f4f2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.calendar_month, color: Color(0xff0bb4b1), size: 28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions ✅ مربوطة هلق
                  const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      QuickAction(
                        icon: Icons.cloud_upload_outlined,
                        label: "Upload\nFiles",
                        onTap: () => context.go('/instructor/files'), // ✅
                      ),
                      const SizedBox(width: 8),
                      QuickAction(
                        icon: Icons.fact_check_outlined,
                        label: "Take\nAttendance",
                        onTap: () => context.go('/instructor/attendance'), // ✅
                      ),
                      const SizedBox(width: 8),
                      QuickAction(
                        icon: Icons.bar_chart_outlined,
                        label: "View\nReports",
                        onTap: () => context.go('/instructor/reports'), // ✅
                      ),
                      const SizedBox(width: 8),
                      QuickAction(
                        icon: Icons.campaign_outlined,
                        label: "New\nAnnouncement",
                        onTap: () => context.go('/instructor/announcements'), // ✅
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // My Courses ✅ مربوط هلق
                  const Text("My Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go('/instructor/course-details'), // ✅
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xff0bb4b1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("CS301", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff0bb4b1))),
                              Text("Data Structures", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          Container(height: 45, width: 1, color: Colors.grey.shade200),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Stat210", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff0bb4b1))),
                              Text("Statistics II", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xffDDF3F2)..style = PaintingStyle.fill;
    final path1 = Path();
    path1.moveTo(size.width * 0.6, 0);
    path1.cubicTo(size.width * 0.3, size.height * 0.1, size.width * 0.1, size.height * 0.4, size.width * 0.3, size.height * 0.7);
    path1.cubicTo(size.width * 0.5, size.height * 0.9, size.width * 0.2, size.height, 0, size.height);
    path1.lineTo(size.width, size.height);
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = const Color(0xffB8E8E6)..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(size.width * 0.9, 0);
    path2.cubicTo(size.width * 0.7, size.height * 0.2, size.width * 0.5, size.height * 0.5, size.width * 0.7, size.height * 0.8);
    path2.cubicTo(size.width * 0.8, size.height * 0.9, size.width * 0.6, size.height, size.width * 0.5, size.height);
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const OverviewCard({super.key, required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// ✅ أضفنا onTap
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // ✅
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xffe8f7f7), shape: BoxShape.circle),
                child: Icon(icon, size: 24, color: const Color(0xff0bb4b1)),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}