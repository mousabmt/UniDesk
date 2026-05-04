import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';

import '../providers_std/prevSemesters_provider.dart';

class Prevsemesters extends StatefulWidget {
  const Prevsemesters({super.key});

  @override
  State<Prevsemesters> createState() => _PrevsemestersState();
}

class _PrevsemestersState extends State<Prevsemesters> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrevsemestersProvider>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrevsemestersProvider>();
    final lang = context.watch<LangProvider>();

    return AppLayout(
      currentIndex: NavIndexes.courses,
      child: Directionality(
        textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Builder(
          builder: (_) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PrevsemestersProvider>().refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final semesters =
                provider.completedCourses?['completed_courses'] as List<dynamic>? ??
                    const [];

            if (semesters.isEmpty) {
              return Center(child: Text(lang.translate('no_courses')));
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<PrevsemestersProvider>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: semesters.length,
                itemBuilder: (context, i) {
                  final semester = semesters[i] as Map<String, dynamic>;
                  final courses = semester['courses'] as List<dynamic>? ?? const [];
                  return _SemesterSection(
                    semester: semester,
                    courses: courses,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SemesterSection extends StatelessWidget {
  const _SemesterSection({
    required this.semester,
    required this.courses,
  });

  final Map<String, dynamic> semester;
  final List<dynamic> courses;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  semester['semester'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (semester['gpa'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6E6E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${lang.translate('gpa')} : ${semester['gpa']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D6E6E),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.black.withValues(alpha: 0.1),
              indent: 66,
              endIndent: 14,
            ),
            itemBuilder: (context, j) {
              final course = courses[j] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D6E6E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['name'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          if (course['id'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${lang.translate('id')}: ${course['id']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (course['grade'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D6E6E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course['grade'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D6E6E),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
