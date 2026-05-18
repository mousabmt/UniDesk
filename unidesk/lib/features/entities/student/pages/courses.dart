import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unidesk/features/auth/authProvider.dart';
import 'package:unidesk/features/entities/student/providers_std/course_provider.dart';
import 'package:unidesk/features/entities/student/widgets/student_refresh_status.dart';
import 'package:unidesk/features/entities/widgets_std/courseWidgets/custom_card.dart';
import 'package:unidesk/features/language/langProvider.dart';

import '../../../../shared/widgets/custom_tealBottom.dart';
import '../../widgets_std/courseWidgets/custom_progessCard.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  // ✅ Local state — exactly like HomePage
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      context.read<CoursesProvider>().loadIfNeeded(token: token);
    });
  }

  // ✅ Matches HomePage's _onRefresh pattern exactly
  Future<void> _refreshCourses() async {
    setState(() => _isRefreshing = true);
    try {
      final token = context.read<AuthProvider>().token;
      await context.read<CoursesProvider>().refresh(token: token);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // ✅ Only provider-owned state comes from context.select
    final isLoading = context.select<CoursesProvider, bool>((p) => p.isLoading);
    final error = context.select<CoursesProvider, String?>((p) => p.error);

    return Scaffold(
      body: Directionality(
        textDirection:
            lang.isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: ColoredBox(
          color: const Color(0xfff9fbfc),
          child: SafeArea(
            bottom: true,
            child: isLoading
                // ✅ Skeleton instead of CircularProgressIndicator
                ? const _CourseSkeleton()
                : RefreshIndicator(
                    onRefresh: _refreshCourses,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        16 + bottomPadding,
                      ),
                      children: [
                        // ✅ Only renders when actually refreshing
                        if (_isRefreshing)
                          StudentRefreshStatus(
                            isRefreshing: _isRefreshing,
                            // ✅ translated
                            message: lang.translate('refreshing_courses'),
                            padding: EdgeInsets.zero,
                          ),

                        // ── Absence Record ──────────────────────────────────
                        Text(
                          lang.translate('absence_record'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (error != null)
                          _ErrorTile(
                            // ✅ translated
                            message: lang.translate('failed_to_load_courses'),
                            onRetry: _refreshCourses,
                          )
                        else
                          Consumer<CoursesProvider>(
                            builder: (context, courses, _) {
                              final list = courses.courses ?? const [];
                              // ✅ Empty state instead of silent empty list
                              if (list.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      lang.translate('no_courses_enrolled'),
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return AbsenceCard(courses: list);
                            },
                          ),

                        const SizedBox(height: 12),

                        TealButton(
                          label: lang.translate('attendance_policy'),
                          onTap: () => context.push('/register-attendance'),
                        ),
                        const SizedBox(height: 10),

                        // ✅ onTap: null — visually disabled until implemented
                        TealButton(
                          label: lang.translate('request_excuse'),
                          onTap:_showComingSoon,
                        ),

                        const SizedBox(height: 24),

                        // ── Academic Progress ───────────────────────────────
                        Text(
                          lang.translate('academic_progress'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ✅ No second loading check — single isLoading at top
                        if (error != null)
                          _ErrorTile(
                            message: lang.translate(
                              'failed_to_load_academic_progress',
                            ),
                            onRetry: _refreshCourses,
                          )
                        else
                          Consumer<CoursesProvider>(
                            builder: (context, courses, _) {
                              final progress = courses.academicProgress;
                              if (progress == null) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      lang.translate('no_progress_data'),
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return AcademicProgressCard(
                                progress: progress,
                                completedCourses: courses.courses ?? const [],
                                showComingSoon: _showComingSoon,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ✅ Skeleton loader with shimmer — mirrors real layout
class _CourseSkeleton extends StatelessWidget {
  const _CourseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        children: [
          _SkeletonBox(height: 20, width: 140, borderRadius: 6),
          const SizedBox(height: 12),
          _SkeletonBox(height: 160, borderRadius: 16),
          const SizedBox(height: 12),
          _SkeletonBox(height: 48, borderRadius: 12),
          const SizedBox(height: 10),
          _SkeletonBox(height: 48, borderRadius: 12),
          const SizedBox(height: 24),
          _SkeletonBox(height: 20, width: 160, borderRadius: 6),
          const SizedBox(height: 12),
          _SkeletonBox(height: 200, borderRadius: 16),
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

// ✅ Reusable error tile with retry — matches HomePage pattern
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