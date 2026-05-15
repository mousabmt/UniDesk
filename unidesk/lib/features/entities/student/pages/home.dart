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
import '../widgets/student_home_widgets.dart';
import '../widgets/student_wave_header_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadIfNeeded();
      context.read<CoursesProvider>().loadIfNeeded();
      context.read<AnnoucProvider>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final profile = context.watch<ProfileProvider>();
    final courses = context.watch<CoursesProvider>();
    final ads = context.watch<AnnoucProvider>();
    final compact = ResponsiveLayout.isCompact(context);

    return Scaffold(
      body: Directionality(
        textDirection: lang.isArabic
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        child: ColoredBox(
          color: const Color(0xfff0f4f8),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (profile.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (profile.error != null)
                  const Text('Error loading data, please try again later.')
                else if (profile.profile != null)
                  SizedBox(
                    width: double.infinity,
                    child: StudentWaveHeaderCard(
                      compact: compact,
                      content: StudentHomeWelcomeText(
                        name: profile.profile!['name']?.toString() ?? '',
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
                  ),

                const SizedBox(height: 16),

                if (courses.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (courses.courses != null)
                  const QuickActionsRow(),

                const SizedBox(height: 16),

                if (profile.profile != null)
                  StatsRow(profile: profile.profile!),

                const SizedBox(height: 16),

                if (ads.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (ads.ads != null)
                  AdvertisementsSection(ads: ads.ads!),
              ],
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
