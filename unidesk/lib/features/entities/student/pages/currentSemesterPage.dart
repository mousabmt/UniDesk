import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';
import '../providers_std/currentSem_provider.dart';

class CurrentSemesterPage extends StatelessWidget {
  const CurrentSemesterPage({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrentSemesterProvider>();
    final lang = context.watch<LangProvider>();

    return AppLayout(
      currentIndex: NavIndexes.home,
      child: Directionality(
        textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child:Builder(builder: (_) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await context.read<CurrentSemesterProvider>().refresh();
                    },
                    child: Text(lang.translate('retry')),
                  ),
                ],
              ),
            );
          }

          final schedule = provider.schdule ?? [];

          if (schedule.isEmpty) {
            return Center(child: Text(lang.translate('no_schedule')));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<CurrentSemesterProvider>().refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: schedule.length,
              itemBuilder: (context, i) {
                final day = schedule[i];
                final courses = day['courses'] as List<dynamic>? ?? [];
                return _DaySection(
                  day:day['day'],
                  courses: courses,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String day;
  final List<dynamic> courses;

  const _DaySection({required this.day, required this.courses});

  @override
  Widget build(BuildContext context) {
        final lang = context.watch<LangProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 6),
          child: Row(
            children: [
              Text(
                 lang.translate(day.toLowerCase()),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),

        // Courses
        ...courses.map((c) {
          final course = c as Map<String, dynamic>;
          return _CourseCard(course: course);
        }),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0D6E6E).withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Left teal accent bar
          Container(
            width: 5,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFF0D6E6E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID + Name
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${course['id']}  ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D6E6E),
                          ),
                        ),
                        TextSpan(
                          text: course['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 13, color: Color(0xFF0D6E6E)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          course['time'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Room
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Color(0xFF0D6E6E)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          course['room'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Instructor
Row(
  children: [
    const Icon(Icons.person_rounded,
        size: 13, color: Color(0xFF0D6E6E)),
    const SizedBox(width: 5),
    Expanded(
      child: Text(
        course['instructor'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4B5563),
        ),
      ),
    ),
  ],
),
                ],
              ),
            ),
          ),

          
        ],
      ),
    );
  }
}
