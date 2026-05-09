import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import '../widgets/instructor_home_widgets.dart';
import '../widgets/instructor_surface_card.dart';
import '../widgets/instructor_wave_header_card.dart';

class InstructorHomePage extends StatelessWidget {
  const InstructorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return ColoredBox(
      color: const Color(0xfff0f4f8),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              width: double.infinity,
              child: InstructorWaveHeaderCard(
                compact: compact,
                content: const InstructorHomeWelcomeText(
                  name: 'Dr. Mousab',
                  subtitle: 'Welcome back,',
                  dateLabel: 'Tuesday, May 14, 2024',
                ),
                leadingCompact: const _InstructorAvatar(radius: 36),
                leadingRegular: const _InstructorAvatar(radius: 40),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Today's Overview",
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
                  children:
                      [
                            InstructorMetricCard(
                              value: "2",
                              label: "Lectures Today",
                              valueColor: Colors.orange,
                              compact: compact,
                            ),
                            InstructorMetricCard(
                              value: "85%",
                              label: "Today Attendance",
                              valueColor: const Color(0xff0bb4b1),
                              compact: compact,
                            ),
                            InstructorMetricCard(
                              value: "24",
                              label: "Students Absent",
                              valueColor: Colors.red,
                              compact: compact,
                            ),
                          ]
                          .map(
                            (card) => SizedBox(width: itemWidth, child: card),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "Next Lecture",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              width: double.infinity,
              child: InstructorNextLectureCard(
                title: 'CS301 - Data Structures',
                time: '10:00 AM - 11:30 AM',
                location: 'Building B, Room 2203',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InstructorQuickActionsGrid(
              actions: [
                InstructorQuickActionData(
                  icon: Icons.cloud_upload_outlined,
                  label: "Upload\nFiles",
                  onTap: () => context.go('/instructor/files'),
                ),
                InstructorQuickActionData(
                  icon: Icons.fact_check_outlined,
                  label: "Take\nAttendance",
                  onTap: () => context.go('/instructor/attendance'),
                ),
                InstructorQuickActionData(
                  icon: Icons.bar_chart_outlined,
                  label: "View\nReports",
                  onTap: () => context.push('/instructor/reports'),
                ),
                InstructorQuickActionData(
                  icon: Icons.campaign_outlined,
                  label: "New\nAnnouncement",
                  onTap: () => context.push('/instructor/announcements'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "My Courses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _InstructorCourseHomeSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xffe0f7f6),
      child: Text(
        'DA',
        style: TextStyle(
          color: const Color(0xff0bb4b1),
          fontSize: radius * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InstructorCourseHomeSection extends StatefulWidget {
  const _InstructorCourseHomeSection();

  @override
  State<_InstructorCourseHomeSection> createState() =>
      _InstructorCourseHomeSectionState();
}

class _InstructorCourseHomeSectionState
    extends State<_InstructorCourseHomeSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instructorId = context.read<AuthProvider>().userId ?? 'D001';
      context.read<InstructorCoursesProvider>().loadIfNeeded(
        instructorId: instructorId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InstructorCoursesProvider>(
      builder: (context, provider, _) {
        if (provider.isCoursesLoading && provider.courses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = provider.courses;
        final primary = courses.isNotEmpty ? courses.first : null;
        final secondary = courses.length > 1 ? courses[1] : primary;

        return GestureDetector(
          onTap: primary == null
              ? null
              : () => context.push(
                  '/instructor/course-details?courseId=${primary.selectionKey}',
                ),
          child: InstructorCourseSummaryCard(
            primaryCode: primary?.id ?? 'Course',
            primaryTitle: primary?.name ?? 'No course data loaded yet',
            secondaryCode: secondary?.id ?? 'Course',
            secondaryTitle: secondary?.name ?? 'Open files to manage courses',
          ),
        );
      },
    );
  }
}
