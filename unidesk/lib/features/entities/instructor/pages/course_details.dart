import 'package:flutter/material.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  int selectedTab = 0;
  final List<String> tabs = ["Overview", "Files", "Assignments", "Students"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4f8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Course Header Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff0a9d9a), Color(0xff0bb4b1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("CS301",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          )),
                        SizedBox(height: 6),
                        Text("Data Structures",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          )),
                        SizedBox(height: 6),
                        Text("Spring 2024",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          )),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.folder,
                        color: Color(0xff80d8d6), size: 60),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("62 Students",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tabs ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff0bb4b1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Text(tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        )),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // ── Course Overview ──
            const Text("Course Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _StatCard(value: "85%", label: "Avg. Attendance", valueColor: const Color(0xff0bb4b1))),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(value: "4", label: "Assignments", valueColor: Colors.black87)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(value: "12", label: "Files", valueColor: Colors.black87)),
              ],
            ),

            const SizedBox(height: 24),

            // ── Recent Files ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Recent Files",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  _buildFileItem(color: Colors.red, label: "PDF", name: "Lecture 5 - Trees.pdf", date: "May 14, 2024", size: "2.4 MB"),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildFileItem(color: Colors.orange, label: "PPTX", name: "Sorting Algorithms.pptx", date: "May 10, 2024", size: "5.1 MB"),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildFileItem(color: Colors.red, label: "PDF", name: "Lecture 4 - Graphs.pdf", date: "May 7, 2024", size: "3.2 MB"),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View All",
                      style: TextStyle(color: Color(0xff0bb4b1))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Upcoming Lectures ──
            const Text("Upcoming Lectures",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lecture 6 - Hashing",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0bb4b1),
                    )),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("May 16, 2024", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(width: 16),
                      Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("10:00 AM - 11:30 AM", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("Room 2203", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem({
    required Color color,
    required String label,
    required String name,
    required String date,
    required String size,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text("$date • $size", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatCard({required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 6),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}