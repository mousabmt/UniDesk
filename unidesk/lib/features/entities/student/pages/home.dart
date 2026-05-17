import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/entities/widgets_std/homeWidgets/actions_row.dart';
import 'package:unidesk/features/entities/widgets_std/homeWidgets/ads.dart';
import 'package:unidesk/features/entities/widgets_std/homeWidgets/stats_row.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

import '../../../language/langProvider.dart';
import '../providers_std/annouc_provider.dart';
import '../providers_std/course_provider.dart';
import '../providers_std/profile_provider.dart';
import '../widgets/student_refresh_status.dart';
import '../widgets/student_home_widgets.dart';
import '../widgets/student_wave_header_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  // ✅ Single load method for all providers
  Future<void> _loadAll() async {
    await Future.wait([
      context.read<ProfileProvider>().loadIfNeeded(),
      context.read<CoursesProvider>().loadIfNeeded(),
      context.read<AnnoucProvider>().loadIfNeeded(),
    ]);
  }

  // ✅ Pull-to-refresh forces all providers to reload
  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await Future.wait([
        context.read<ProfileProvider>().refresh(),
        context.read<CoursesProvider>().refresh(),
        context.read<AnnoucProvider>().refresh(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final compact = ResponsiveLayout.isCompact(context);

    // ✅ Single loading state — wait for all providers
    final isLoading =
        context.select<ProfileProvider, bool>((p) => p.isLoading) ||
        context.select<CoursesProvider, bool>((p) => p.isLoading) ||
        context.select<AnnoucProvider, bool>((p) => p.isLoading);

    return Scaffold(
      body: Directionality(
        textDirection: lang.isArabic
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: ColoredBox(
          color: const Color(0xfff0f4f8),
          child: SafeArea(
            bottom: true, // ✅ respect gesture nav bar
            child: isLoading
                ? const _HomeSkeleton() // ✅ skeleton instead of spinners
                : RefreshIndicator(
                    // ✅ pull-to-refresh
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16 + bottomPadding, // ✅ proper bottom padding
                      ),
                      children: [
                        StudentRefreshStatus(
                          isRefreshing: _isRefreshing,
                          message: 'Refreshing home data...',
                          padding: EdgeInsets.zero,
                        ),
                        // ✅ Consumer only rebuilds header section
                        Consumer<ProfileProvider>(
                          builder: (context, profile, _) {
                            if (profile.error != null) {
                              return _ErrorTile(
                                message: profile.error!,
                                onRetry: () =>
                                    context.read<ProfileProvider>().refresh(),
                              );
                            }
                            if (profile.profile == null) {
                              return const SizedBox.shrink();
                            }
                            return SizedBox(
                              width: double.infinity,
                              child: StudentWaveHeaderCard(
                                compact: compact,
                                content: StudentHomeWelcomeText(
                                  name:
                                      profile.profile!['name']?.toString() ??
                                      '',
                                  subtitle: lang.translate('welcome_back'),
                                  dateLabel: _formatDateLabel(lang.isArabic),
                                ),
                                leadingCompact: _StudentAvatar(
                                  initials: _extractInitials(
                                    profile.profile!['name']?.toString() ?? '',
                                  ),
                                  radius: 36,
                                ),
                                leadingRegular: _StudentAvatar(
                                  initials: _extractInitials(
                                    profile.profile!['name']?.toString() ?? '',
                                  ),
                                  radius: 40,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ✅ Consumer only rebuilds actions section
                        Consumer<CoursesProvider>(
                          builder: (context, courses, _) {
                            if (courses.error != null) {
                              return _ErrorTile(
                                message: courses.error!,
                                onRetry: () =>
                                    context.read<CoursesProvider>().refresh(),
                              );
                            }
                            if (courses.courses == null) {
                              return const SizedBox.shrink();
                            }
                            return const QuickActionsRow();
                          },
                        ),

                        const SizedBox(height: 16),

                        // ✅ Consumer only rebuilds stats section
                        Consumer<ProfileProvider>(
                          builder: (context, profile, _) {
                            if (profile.profile == null) {
                              return const SizedBox.shrink();
                            }
                            return StatsRow(profile: profile.profile!);
                          },
                        ),

                        const SizedBox(height: 16),

                        // ✅ Consumer only rebuilds ads section
                        Consumer<AnnoucProvider>(
                          builder: (context, ads, _) {
                            if (ads.error != null) {
                              return _ErrorTile(
                                message: ads.error!,
                                onRetry: () =>
                                    context.read<AnnoucProvider>().refresh(),
                              );
                            }
                            if (ads.ads == null) {
                              return const SizedBox.shrink();
                            }
                            return AdvertisementsSection(ads: ads.ads!);
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

  String _formatDateLabel(bool isArabic) {
    final locale = isArabic ? 'ar' : 'en';
    return DateFormat('EEEE, MMMM d, y', locale).format(DateTime.now());
  }

  String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0]).join();
    return initials.isEmpty ? 'ST' : initials.toUpperCase();
  }
}

// ✅ Skeleton loader — shows while all providers load
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SkeletonBox(height: 140, borderRadius: 20),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        _SkeletonBox(height: 160, borderRadius: 20),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.borderRadius});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ✅ Reusable error tile with retry
class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.initials, required this.radius});

  final String initials;
  final double radius;

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
