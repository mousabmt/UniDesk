import 'package:flutter/material.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

import '../widgets/instructor_file_item.dart';
import '../widgets/instructor_surface_card.dart';

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
    final compact = ResponsiveLayout.isCompact(context);

    return Scaffold(
      backgroundColor: const Color(0xfff0f4f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackHeader = constraints.maxWidth < 420;

                    if (stackHeader) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _CourseHeaderText(),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _HeaderMeta(compact: true),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: _CourseHeaderText()),
                        _HeaderMeta(compact: false),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTab == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedTab = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? const Color(0xff0bb4b1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Course Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 10.0;
                  final columns = ResponsiveLayout.columnsForWidth(
                    constraints.maxWidth,
                    compact: 1,
                    medium: 3,
                    wide: 3,
                  );
                  final itemWidth = columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      InstructorMetricCard(
                        value: "85%",
                        label: "Avg. Attendance",
                        valueColor: const Color(0xff0bb4b1),
                        compact: compact,
                      ),
                      InstructorMetricCard(
                        value: "4",
                        label: "Assignments",
                        valueColor: Colors.black87,
                        compact: compact,
                      ),
                      InstructorMetricCard(
                        value: "12",
                        label: "Files",
                        valueColor: Colors.black87,
                        compact: compact,
                      ),
                    ]
                        .map((card) => SizedBox(width: itemWidth, child: card))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              const InstructorSurfaceCard(
                padding: EdgeInsets.zero,
                child: _RecentFilesSection(),
              ),
              const SizedBox(height: 24),
              const Text(
                "Upcoming Lectures",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InstructorSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lecture 6 - Hashing",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0bb4b1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (compact) ...[
                      const _LectureMetaRow(
                        icon: Icons.calendar_today_outlined,
                        text: "May 16, 2024",
                      ),
                      const SizedBox(height: 6),
                      const _LectureMetaRow(
                        icon: Icons.access_time_outlined,
                        text: "10:00 AM - 11:30 AM",
                      ),
                    ] else
                      const Row(
                        children: [
                          _LectureMetaRow(
                            icon: Icons.calendar_today_outlined,
                            text: "May 16, 2024",
                          ),
                          SizedBox(width: 16),
                          _LectureMetaRow(
                            icon: Icons.access_time_outlined,
                            text: "10:00 AM - 11:30 AM",
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    const _LectureMetaRow(
                      icon: Icons.location_on_outlined,
                      text: "Room 2203",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentFilesSection extends StatelessWidget {
  const _RecentFilesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Files",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const InstructorFileItem(
          color: Colors.red,
          label: "PDF",
          name: "Lecture 5 - Trees.pdf",
          date: "May 14, 2024",
          size: "2.4 MB",
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        const InstructorFileItem(
          color: Colors.orange,
          label: "PPTX",
          name: "Sorting Algorithms.pptx",
          date: "May 10, 2024",
          size: "5.1 MB",
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        const InstructorFileItem(
          color: Colors.red,
          label: "PDF",
          name: "Lecture 4 - Graphs.pdf",
          date: "May 7, 2024",
          size: "3.2 MB",
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "View All",
            style: TextStyle(color: Color(0xff0bb4b1)),
          ),
        ),
      ],
    );
  }
}

class _CourseHeaderText extends StatelessWidget {
  const _CourseHeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CS301",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Data Structures",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Spring 2024",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _HeaderMeta extends StatelessWidget {
  final bool compact;

  const _HeaderMeta({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.folder,
          color: const Color(0xff80d8d6),
          size: compact ? 48 : 60,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "62 Students",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _LectureMetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LectureMetaRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
