import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/core/constants/constants.dart';
import 'package:unidesk/features/language/langProvider.dart';
import 'package:unidesk/shared/widgets/app_layout.dart';
import 'package:unidesk/shared/widgets/custom_tealIcon.dart';
import '../providers_std/course_provider.dart'; 
class GradesPage extends StatelessWidget {
  const GradesPage({super.key});



  // helper — grade number to letter


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoursesProvider>();
    final lang = context.watch<LangProvider>();

    return AppLayout(
      currentIndex: NavIndexes.courses,
      child: Directionality(
        textDirection: lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Builder(builder: (_) {
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
                      await context.read<CoursesProvider>().refresh();
                    },
                    child: Text(lang.translate('retry')),
                  ),
                ],
              ),
            );
          }

          final grades = provider.courses ?? [];

          if (grades.isEmpty) {
            return Center(child: Text(lang.translate('no_grades')));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<CoursesProvider>().refresh();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final course = grades[i];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Grade badge
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
child: Center(
  child: TealIconBox(
    child: const Icon(
      Icons.menu_book_rounded,
      color: Colors.white,
      size: 20,
    ),
  ),
),
                      ),
                      const SizedBox(width: 12),
                      // Course info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              course['instructor'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Numeric grade
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${course['grade']}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${course['credits']} ${lang.translate('credits')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}