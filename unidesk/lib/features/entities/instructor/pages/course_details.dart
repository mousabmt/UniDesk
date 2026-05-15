import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_details.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_course_file.dart';
import 'package:unidesk/features/entities/instructor/course_management/models/instructor_managed_course.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/entities/instructor/course_management/widgets/course_file_list_item.dart';
import 'package:unidesk/features/entities/instructor/course_management/widgets/course_student_list_item.dart';
import 'package:unidesk/features/entities/instructor/widgets/instructor_surface_card.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key, this.initialCourseId});

  final String? initialCourseId;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

enum _CourseDetailsTab { overview, files, assignments, students }

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  _CourseDetailsTab _selectedTab = _CourseDetailsTab.overview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instructorId = context.read<AuthProvider>().userId ?? 'D001';
      context.read<InstructorCoursesProvider>().loadIfNeeded(
        instructorId: instructorId,
        preferredCourseId: widget.initialCourseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);
    final instructorId = context.select<AuthProvider, String>(
      (auth) => auth.userId ?? 'D001',
    );

    return ColoredBox(
      color: const Color(0xfff0f4f8),
      child: SafeArea(
        bottom: false,
        child: Consumer<InstructorCoursesProvider>(
          builder: (context, provider, _) {
            final details = provider.currentCourseDetails;

            if (provider.isCoursesLoading && provider.courses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.coursesError != null && provider.courses.isEmpty) {
              return _PageStateMessage(
                message: provider.coursesError!,
                actionLabel: 'Retry',
                onRetry: () => provider.refresh(instructorId: instructorId),
              );
            }

            if (provider.isDetailsLoading && details == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.detailsError != null && details == null) {
              return _PageStateMessage(
                message: provider.detailsError!,
                actionLabel: 'Retry',
                onRetry: () => provider.refresh(
                  instructorId: instructorId,
                  preferredCourseId: widget.initialCourseId,
                ),
              );
            }

            if (details == null) {
              return const _PageStateMessage(
                message: 'Choose a course to view its details.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CourseHeader(details: details),
                const SizedBox(height: 20),
                _CourseSwitcher(
                  selectedCourseKey: provider.selectedCourseKey,
                  courses: provider.courses,
                  onChanged: (courseId) async {
                    if (courseId == null) {
                      return;
                    }
                    await provider.selectCourse(
                      instructorId: instructorId,
                      courseId: courseId,
                    );
                  },
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TabChip(
                        label: 'Overview',
                        selected: _selectedTab == _CourseDetailsTab.overview,
                        onTap: () => setState(() {
                          _selectedTab = _CourseDetailsTab.overview;
                        }),
                      ),
                      _TabChip(
                        label: 'Files',
                        selected: _selectedTab == _CourseDetailsTab.files,
                        onTap: () => setState(() {
                          _selectedTab = _CourseDetailsTab.files;
                        }),
                      ),
                      _TabChip(
                        label: 'Assignments',
                        selected: _selectedTab == _CourseDetailsTab.assignments,
                        onTap: () => setState(() {
                          _selectedTab = _CourseDetailsTab.assignments;
                        }),
                      ),
                      _TabChip(
                        label: 'Students',
                        selected: _selectedTab == _CourseDetailsTab.students,
                        onTap: () => setState(() {
                          _selectedTab = _CourseDetailsTab.students;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedTab == _CourseDetailsTab.overview)
                  _OverviewTab(details: details, compact: compact)
                else if (_selectedTab == _CourseDetailsTab.files)
                  _FilesTab(
                    files: details.files.where((file) {
                      // Only show lecture and exam files, explicitly exclude assignments
                      return (file.category == InstructorCourseFileCategory.lecture ||
                              file.category == InstructorCourseFileCategory.exam) &&
                          file.category != InstructorCourseFileCategory.assignment;
                    }).toList(),
                  )
                else if (_selectedTab == _CourseDetailsTab.assignments)
                  _AssignmentsTab(
                    courseId: details.course.id,
                    sectionId: details.course.sectionId.isNotEmpty
                        ? details.course.sectionId
                        : details.course.lectureId,
                    files: details.files,
                  )
                else
                  _StudentsTab(students: details.students),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.details});

  final InstructorCourseDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          final headerText = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.course.id,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                details.course.name,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                details.course.term,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          );

          final meta = Column(
            crossAxisAlignment: stackHeader
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.folder_copy_outlined,
                color: const Color(0xff80d8d6),
                size: stackHeader ? 48 : 60,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${details.course.studentsEnrolled} Students',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          );

          if (stackHeader) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [headerText, const SizedBox(height: 12), meta],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headerText),
              meta,
            ],
          );
        },
      ),
    );
  }
}

class _CourseSwitcher extends StatelessWidget {
  const _CourseSwitcher({
    required this.selectedCourseKey,
    required this.courses,
    required this.onChanged,
  });

  final String? selectedCourseKey;
  final List<InstructorManagedCourse> courses;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourseKey,
          isExpanded: true,
          selectedItemBuilder: (context) {
            return courses
                .map(
                  (course) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      course.displayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList();
          },
          items: courses
              .map<DropdownMenuItem<String>>(
                (course) => DropdownMenuItem<String>(
                  value: course.selectionKey,
                  child: Text(
                    course.displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff0bb4b1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.details, required this.compact});

  final InstructorCourseDetails details;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Overview',
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
                : (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                InstructorMetricCard(
                  value: details.summary.averageAttendanceLabel,
                  label: 'Avg. Attendance',
                  valueColor: const Color(0xff0bb4b1),
                  compact: compact,
                ),
                InstructorMetricCard(
                  value: details.summary.assignmentsCount.toString(),
                  label: 'Assignments',
                  valueColor: Colors.black87,
                  compact: compact,
                ),
                InstructorMetricCard(
                  value: details.summary.filesCount.toString(),
                  label: 'Files',
                  valueColor: Colors.black87,
                  compact: compact,
                ),
              ].map((card) => SizedBox(width: itemWidth, child: card)).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Upcoming Lecture',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InstructorSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.upcomingLecture.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0bb4b1),
                ),
              ),
              const SizedBox(height: 10),
              _LectureMetaRow(
                icon: Icons.calendar_today_outlined,
                text: details.upcomingLecture.dateLabel,
              ),
              const SizedBox(height: 6),
              _LectureMetaRow(
                icon: Icons.access_time_outlined,
                text: details.upcomingLecture.timeLabel,
              ),
              const SizedBox(height: 6),
              _LectureMetaRow(
                icon: Icons.location_on_outlined,
                text: details.upcomingLecture.locationLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilesTab extends StatelessWidget {
  const _FilesTab({required this.files});

  final List<InstructorCourseFile> files;

  @override
  Widget build(BuildContext context) {
    return _FileSectionCard(
      title: 'Course Files',
      files: files,
      emptyMessage: 'No uploaded files yet.',
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({
    required this.courseId,
    required this.sectionId,
    required this.files,
  });

  final String courseId;
  final String sectionId;
  final List<InstructorCourseFile> files;

  @override
  Widget build(BuildContext context) {
    final assignmentFiles = files
        .where(
          (file) => file.category == InstructorCourseFileCategory.assignment,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assignment Materials',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: () => context.push(
                '/instructor/assignments-list?courseId=$courseId&sectionId=$sectionId',
              ),
              child: const Text(
                'View Assignments',
                style: TextStyle(color: Color(0xff0bb4b1)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.push(
                '/instructor/add-assignment?courseId=$courseId&sectionId=$sectionId',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0bb4b1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Assignment'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FileSectionCard(
          title: 'Uploaded Assignment Files',
          files: assignmentFiles,
          emptyMessage: 'No assignment files uploaded yet.',
        ),
      ],
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab({required this.students});

  final List<InstructorCourseStudent> students;

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      padding: EdgeInsets.zero,
      child: students.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No students are enrolled in this course yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              children: List.generate(students.length, (index) {
                return Column(
                  children: [
                    CourseStudentListItem(student: students[index]),
                    if (index < students.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
            ),
    );
  }
}

class _FileSectionCard extends StatelessWidget {
  const _FileSectionCard({
    required this.title,
    required this.files,
    required this.emptyMessage,
  });

  final String title;
  final List<InstructorCourseFile> files;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InstructorSurfaceCard(
          padding: EdgeInsets.zero,
          child: files.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    emptyMessage,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: List.generate(files.length, (index) {
                    return Column(
                      children: [
                        CourseFileListItem(file: files[index]),
                        if (index < files.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

class _LectureMetaRow extends StatelessWidget {
  const _LectureMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _PageStateMessage extends StatelessWidget {
  const _PageStateMessage({
    required this.message,
    this.actionLabel,
    this.onRetry,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            if (actionLabel != null && onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onRetry, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
