import 'package:flutter/material.dart';

class AddFilesPage extends StatefulWidget {
  const AddFilesPage({super.key});

  @override
  State<AddFilesPage> createState() => _AddFilesPageState();
}

class _AddFilesPageState extends State<AddFilesPage> {
  String? selectedCourse;
  int selectedCategory = 0;
  final List<String> categories = ["Lecture", "Assignment", "Exam"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4f8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Greeting Card ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0, top: 0, bottom: 0,
                      child: SizedBox(width: 120, child: CustomPaint(painter: _WavePainter())),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xffe0f7f6),
                          backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=68"),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Hello Dr. Rame",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Upload and manage your course files.",
                              style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Select Course ──
            const Text("Select Course",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCourse,
                  hint: const Text("CS301 - Data Structures"),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "CS301", child: Text("CS301 - Data Structures")),
                    DropdownMenuItem(value: "STAT210", child: Text("STAT210 - Statistics II")),
                  ],
                  onChanged: (value) => setState(() => selectedCourse = value),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── File Category ──
            const Text("File Category",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(categories.length, (index) {
                final isSelected = selectedCategory == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategory = index),
                    child: Container(
                      margin: EdgeInsets.only(right: index < categories.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff0bb4b1) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Text(
                        categories[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ── Upload Area ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xff0bb4b1), width: 1.5, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 60, color: Color(0xff0bb4b1)),
                  const SizedBox(height: 10),
                  const Text("Browse or drag & drop files here",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0bb4b1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text("Upload File",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Recent Files ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Files",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All",
                    style: TextStyle(color: Color(0xff0bb4b1))),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _buildFileItem(
              color: Colors.red,
              label: "PDF",
              name: "Lecture 5 - Trees.pdf",
              date: "May 14, 2024",
              size: "2.4 MB",
            ),
            const Divider(height: 1),
            _buildFileItem(
              color: Colors.orange,
              label: "PPTX",
              name: "Sorting Algorithms.pptx",
              date: "May 10, 2024",
              size: "5.1 MB",
            ),
            const Divider(height: 1),
            _buildFileItem(
              color: Colors.red,
              label: "PDF",
              name: "Lecture 4 - Graphs.pdf",
              date: "May 7, 2024",
              size: "3.2 MB",
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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

// ── Wave Painter ──
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