import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unidesk/features/language/langProvider.dart';
import '../../../../shared/widgets/custom_tealIcon.dart';
class AcademicProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final List<Map<String, dynamic>> completedCourses;

  const AcademicProgressCard({
    super.key,
    required this.progress,
    required this.completedCourses,
  });

  @override
  Widget build(BuildContext context) {
  final lang = context.watch<LangProvider>(); 

    final items = [
      _ProgressItem(
        icon: Icons.school_rounded,
        label: lang.translate('previous_semesters'),
        onTap: () {
          context.push('/completed-courses');
        },
      ),
_ProgressItem(
  icon: Icons.assignment_rounded,
  label: lang.translate('grades'),
  onTap: () {
    context.push('/courses-grades');
  },
),
      _ProgressItem(
        icon: Icons.show_chart_rounded,
        label: lang.translate('gpa_calc'),
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return _ProgressRow(
            item: items[i],
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}

class _ProgressItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ProgressRow extends StatelessWidget {
  final _ProgressItem item;
  final bool showDivider;

  const _ProgressRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                 TealIconBox(
                child: Icon(item.icon, color: Colors.white, size: 20),
              ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.black.withValues(alpha: 0.1),
            indent: 66,
            endIndent: 14,
          ),
      ],
    );
  }
}
