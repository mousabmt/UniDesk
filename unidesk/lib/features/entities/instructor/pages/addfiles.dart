import 'package:flutter/material.dart';

import '../widgets/instructor_file_item.dart';
import '../widgets/instructor_surface_card.dart';
import '../widgets/instructor_wave_header_card.dart';

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
            InstructorWaveHeaderCard(
              compact: MediaQuery.sizeOf(context).width < 600,
              compactBreakpoint: 360,
              minHeightCompact: 150,
              minHeightRegular: 120,
              waveWidthCompact: 110,
              waveWidthRegular: 120,
              leadingCompact: const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xffe0f7f6),
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=68"),
              ),
              leadingRegular: const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xffe0f7f6),
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=68"),
              ),
              content: const _FilesGreetingText(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Course",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InstructorSurfaceCard(
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCourse,
                  hint: const Text("CS301 - Data Structures"),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: "CS301",
                      child: Text("CS301 - Data Structures"),
                    ),
                    DropdownMenuItem(
                      value: "STAT210",
                      child: Text("STAT210 - Statistics II"),
                    ),
                  ],
                  onChanged: (value) => setState(() => selectedCourse = value),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "File Category",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(categories.length, (index) {
                final isSelected = selectedCategory == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategory = index),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < categories.length - 1 ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xff0bb4b1) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xff0bb4b1),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 60,
                    color: Color(0xff0bb4b1),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Browse or drag & drop files here",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0bb4b1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text(
                        "Upload File",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Files",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Color(0xff0bb4b1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const InstructorFileItem(
              color: Colors.red,
              label: "PDF",
              name: "Lecture 5 - Trees.pdf",
              date: "May 14, 2024",
              size: "2.4 MB",
            ),
            const Divider(height: 1),
            const InstructorFileItem(
              color: Colors.orange,
              label: "PPTX",
              name: "Sorting Algorithms.pptx",
              date: "May 10, 2024",
              size: "5.1 MB",
            ),
            const Divider(height: 1),
            const InstructorFileItem(
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
}

class _FilesGreetingText extends StatelessWidget {
  const _FilesGreetingText();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Hello Dr. Rame",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Upload and manage your course files.",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
