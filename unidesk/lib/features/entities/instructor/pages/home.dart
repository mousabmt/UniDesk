import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unidesk/core/services/student_api.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/instructor/course_management/providers/instructor_courses_provider.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

import '../widgets/instructor_home_widgets.dart';
import '../widgets/instructor_surface_card.dart';
import '../widgets/instructor_wave_header_card.dart';

// ✅ Re-use the same StudentRefreshStatus widget from student side
import 'package:unidesk/features/entities/student/widgets/student_refresh_status.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  Map<String, dynamic>? _homeData;
  bool _isLoading = true;
  bool _isRefreshing = false; // ✅ local state — same pattern as StudentHomePage
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
      // ✅ Refresh: keep existing content visible, just show refresh banner
      setState(() {
        _isRefreshing = true;
        _error = null;
      });
    } else {
      // ✅ Initial load: show skeleton
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
    final lang = context.watch<LangProvider>();
    final compact = ResponsiveLayout.isCompact(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // ── Parse data safely ────────────────────────────────────────────────────
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

    final instructorName =
        instructor['name']?.toString() ??
        lang.translate('instructor_fallback_name');

    final nextLectureTitle = nextLecture.isEmpty
        ? lang.translate('no_upcoming_lecture')
        : '${nextLecture['course_code'] ?? ''} - ${nextLecture['course_name'] ?? ''}';

    final nextLectureTime = nextLecture.isEmpty
        ? lang.translate('schedule_unavailable')
        : '${_formatTime(nextLecture['start_time'])} - ${_formatTime(nextLecture['end_time'])}';

    final nextLectureLocation =
        nextLecture['room']?.toString() ??
        lang.translate('room_unavailable');

    return Directionality(
      // ✅ RTL support — was missing entirely
      textDirection:
          lang.isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xfff0f4f8),
        child: SafeArea(
          bottom: true, // ✅ was false — respect gesture nav bar
          child: _isLoading
              // ✅ Skeleton instead of CircularProgressIndicator
              ? const _InstructorHomeSkeleton()
              : RefreshIndicator(
                  onRefresh: () => _loadHomeData(isRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + bottomPadding, // ✅ proper bottom padding
                    ),
                    children: [
                      // ✅ Reuses StudentRefreshStatus — same as StudentHomePage
                      if (_isRefreshing)
                        StudentRefreshStatus(
                          isRefreshing: _isRefreshing,
                          // ✅ translated
                          message: lang.translate('refreshing_home_data'),
                          padding: EdgeInsets.zero,
                        ),

                      // ── Error state ─────────────────────────────────────
                      if (_error != null)
                        _ErrorTile(
                          // ✅ translated
                          message: lang.translate('failed_to_load_home'),
                          onRetry: _loadHomeData,
                        )
                      else ...[
                        // ── Header ───────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: InstructorWaveHeaderCard(
                            compact: compact,
                            content: InstructorHomeWelcomeText(
                              name: instructorName,
                              // ✅ translated
                              subtitle: lang.translate('welcome_back'),
                              dateLabel: _formatDateLabel(lang.isArabic),
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

                        // ── Today's Overview ─────────────────────────────
                        Text(
                          // ✅ translated
                          lang.translate('todays_overview'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 10.0; // ✅ const
                            final columns = ResponsiveLayout.columnsForWidth(
                              constraints.maxWidth,
                              compact: 1,
                              medium: 3,
                              wide: 3,
                            );
                            final itemWidth = columns == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth -
                                      (spacing * (columns - 1))) /
                                  columns;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                InstructorMetricCard(
                                  value: todayLectures.length.toString(),
                                  // ✅ translated
                                  label: lang.translate('lectures_today'),
                                  valueColor: Colors.orange,
                                  compact: compact,
                                ),
                                InstructorMetricCard(
                                  value:
                                      todayAttendance['attendance_percentage']
                                          ?.toString() ??
                                      '0%',
                                  // ✅ translated
                                  label: lang.translate('today_attendance'),
                                  valueColor: const Color(0xff0bb4b1),
                                  compact: compact,
                                ),
                                InstructorMetricCard(
                                  value:
                                      todayAttendance['absent']?.toString() ??
                                      '0',
                                  // ✅ translated
                                  label: lang.translate('students_absent'),
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

                        // ── Next Lecture ─────────────────────────────────
                        Text(
                          // ✅ translated
                          lang.translate('next_lecture'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

                        // ── Quick Actions ────────────────────────────────
                        Text(
                          // ✅ translated
                          lang.translate('quick_actions'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InstructorQuickActionsGrid(
                          actions: [
                            InstructorQuickActionData(
                              icon: Icons.cloud_upload_outlined,
                              // ✅ translated
                              label: lang.translate('upload_files'),
                              onTap: () => context.go('/instructor/files'),
                            ),
                            InstructorQuickActionData(
                              icon: Icons.fact_check_outlined,
                              // ✅ translated
                              label: lang.translate('take_attendance'),
                              onTap: () =>
                                  context.go('/instructor/attendance'),
                            ),
                            InstructorQuickActionData(
                              icon: Icons.bar_chart_outlined,
                              // ✅ translated
                              label: lang.translate('view_reports'),
                              onTap: () =>
                                  context.push('/instructor/reports'),
                            ),
                            InstructorQuickActionData(
                              icon: Icons.campaign_outlined,
                              // ✅ translated
                              label: lang.translate('new_announcement'),
                              onTap: () =>
                                  context.push('/instructor/announcements'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── My Courses ───────────────────────────────────
                        Text(
                          // ✅ translated
                          lang.translate('my_courses'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _InstructorCourseHomeSection(),
                        const SizedBox(height: 30),
                      ],
                    ],
                  ),
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

  // ✅ Matches StudentHomePage _formatDateLabel
  String _formatDateLabel(bool isArabic) {
    final locale = isArabic ? 'ar' : 'en';
    return DateFormat('EEEE, MMMM d, y', locale).format(DateTime.now());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ Skeleton loader — mirrors the real layout while loading
// ─────────────────────────────────────────────────────────────────────────────
class _InstructorHomeSkeleton extends StatelessWidget {
  const _InstructorHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          _SkeletonBox(height: 140, borderRadius: 20),
          const SizedBox(height: 16),
          // Section title
          _SkeletonBox(height: 20, width: 160, borderRadius: 6),
          const SizedBox(height: 12),
          // Metric cards row
          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _SkeletonBox(height: 80, borderRadius: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Section title
          _SkeletonBox(height: 20, width: 120, borderRadius: 6),
          const SizedBox(height: 12),
          // Next lecture card
          _SkeletonBox(height: 100, borderRadius: 16),
          const SizedBox(height: 24),
          // Section title
          _SkeletonBox(height: 20, width: 130, borderRadius: 6),
          const SizedBox(height: 12),
          // Quick actions grid
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _SkeletonBox(height: 72, borderRadius: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Section title
          _SkeletonBox(height: 20, width: 110, borderRadius: 6),
          const SizedBox(height: 12),
          // Courses card
          _SkeletonBox(height: 120, borderRadius: 16),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.borderRadius,
    this.width = double.infinity,
  });

  final double height;
  final double borderRadius;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ Shared error tile with retry — matches CoursePage & StudentHomePage
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LangProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffff0f0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xffd36b6b)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xffd36b6b)),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            // ✅ translated
            child: Text(lang.translate('retry')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Instructor avatar
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// ✅ Courses section — skeleton instead of CircularProgressIndicator
// ─────────────────────────────────────────────────────────────────────────────
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
        // ✅ Skeleton instead of CircularProgressIndicator
        if (provider.isCoursesLoading && provider.courses.isEmpty) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
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