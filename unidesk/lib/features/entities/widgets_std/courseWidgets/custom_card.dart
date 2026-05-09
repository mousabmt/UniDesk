import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_tealIcon.dart';

class AbsenceCard extends StatelessWidget {
  const AbsenceCard({
    super.key,
    required this.courses,
  });

  final List<Map<String, dynamic>> courses;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        children: List.generate(courses.length, (i) {
          final course = courses[i];
          return AbsenceRow(
            code: course['id']?.toString() ?? '',
            name: course['name']?.toString() ?? '',
            absences: _toInt(course['absences']),
            showDivider: i < courses.length - 1,
          );
        }),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AbsenceRow extends StatelessWidget {
  const AbsenceRow({
    super.key,
    required this.code,
    required this.name,
    required this.absences,
    required this.showDivider,
  });

  final String code;
  final String name;
  final int absences;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              const TealIconBox(
                child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$absences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: absences > 0
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.black.withValues(alpha: 0.1),
            indent: 68,
            endIndent: 14,
          ),
      ],
    );
  }
}
