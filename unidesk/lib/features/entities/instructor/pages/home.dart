import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import '../widgets/instructor_home_widgets.dart';
import '../widgets/instructor_surface_card.dart';
import '../widgets/instructor_wave_header_card.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  Map<String, dynamic>? _homeData;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  Future<void> _loadHomeData({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final token = context.read<AuthProvider>().token;
      final response = await StudentApi.getInstructorProfile(token: token);
      if (!mounted) return;
      setState(() {
        _homeData = response;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);
    final instructor = _homeData?['instructor'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            _homeData!['instructor'] as Map<String, dynamic>,
          )
        : <String, dynamic>{};
    final todayAttendance =
        _homeData?['today_attendance'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            _homeData!['today_attendance'] as Map<String, dynamic>,
          )
        : <String, dynamic>{};
    final nextLecture = _homeData?['next_lecture'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            _homeData!['next_lecture'] as Map<String, dynamic>,
          )
        : <String, dynamic>{};
    final todayLectures = _homeData?['today_lectures'] is List
        ? List<Map<String, dynamic>>.from(
            (_homeData!['today_lectures'] as List).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          )
        : <Map<String, dynamic>>[];
    final instructorName = instructor['name']?.toString() ?? 'Instructor';
    final nextLectureTitle = nextLecture.isEmpty
        ? 'No upcoming lecture'
        : '${nextLecture['course_code'] ?? ''} - ${nextLecture['course_name'] ?? ''}';
    final nextLectureTime = nextLecture.isEmpty
        ? 'Schedule unavailable'
        : '${_formatTime(nextLecture['start_time'])} - ${_formatTime(nextLecture['end_time'])}';
    final nextLectureLocation =
        nextLecture['room']?.toString() ?? 'Room unavailable';

    return ColoredBox(
      color: const Color(0xfff0f4f8),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _loadHomeData(isRefresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isRefreshing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Refreshing home data...',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadHomeData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: InstructorWaveHeaderCard(
                    compact: compact,
                    content: InstructorHomeWelcomeText(
                      name: instructorName,
                      subtitle: 'Welcome back,',
                      dateLabel: DateFormat(
                        'EEEE, MMMM d, y',
                      ).format(DateTime.now()),
                    ),
                    leadingCompact: _InstructorAvatar(
                      radius: 36,
                      initials: _extractInitials(instructorName),
                    ),
                    leadingRegular: _InstructorAvatar(
                      radius: 40,
                      initials: _extractInitials(instructorName),
                    ),
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
                                  value: todayLectures.length.toString(),
                                  label: "Lectures Today",
                                  valueColor: Colors.orange,
                                  compact: compact,
                                ),
                                InstructorMetricCard(
                                  value:
                                      todayAttendance['attendance_percentage']
                                          ?.toString() ??
                                      '0%',
                                  label: "Today Attendance",
                                  valueColor: const Color(0xff0bb4b1),
                                  compact: compact,
                                ),
                                InstructorMetricCard(
                                  value:
                                      todayAttendance['absent']?.toString() ??
                                      '0',
                                  label: "Students Absent",
                                  valueColor: Colors.red,
                                  compact: compact,
                                ),
                              ]
                              .map(
                                (card) =>
                                    SizedBox(width: itemWidth, child: card),
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
                SizedBox(
                  width: double.infinity,
                  child: InstructorNextLectureCard(
                    title: nextLectureTitle,
                    time: nextLectureTime,
                    location: nextLectureLocation,
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
            ],
          ),
        ),
      ),
    );
  }

  String _extractInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0]).join();
    return initials.isEmpty ? 'IN' : initials.toUpperCase();
  }

  String _formatTime(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '--';

    try {
      final parsed = DateFormat('HH:mm:ss').parse(raw);
      return DateFormat('h:mm a').format(parsed);
    } catch (_) {
      return raw;
    }
  }
}

class _InstructorAvatar extends StatelessWidget {
  const _InstructorAvatar({required this.radius, required this.initials});

  final double radius;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xffe0f7f6),
      child: Text(
        initials,
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
