import 'package:flutter/material.dart';
import 'package:unidesk/shared/widgets/responsive_layout.dart';

import 'instructor_surface_card.dart';

class InstructorHomeWelcomeText extends StatelessWidget {
  final String name;
  final String subtitle;
  final String dateLabel;

  const InstructorHomeWelcomeText({
    super.key,
    required this.name,
    required this.subtitle,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}

class InstructorNextLectureCard extends StatelessWidget {
  final String title;
  final String time;
  final String location;

  const InstructorNextLectureCard({
    super.key,
    required this.title,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return InstructorSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LectureInfo(title: title, time: time, location: location),
                const SizedBox(height: 12),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _LectureInfo(
                  title: title,
                  time: time,
                  location: location,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LectureInfo extends StatelessWidget {
  final String title;
  final String time;
  final String location;

  const _LectureInfo({
    required this.title,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff0bb4b1),
          ),
        ),
        const SizedBox(height: 6),
        Text(time, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(location, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}



class InstructorQuickActionData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const InstructorQuickActionData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class InstructorQuickActionsGrid extends StatelessWidget {
  final List<InstructorQuickActionData> actions;

  const InstructorQuickActionsGrid({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
        final columns = ResponsiveLayout.columnsForWidth(
          constraints.maxWidth,
          compact: 2,
          medium: 4,
          wide: 4,
        );
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions
              .map(
                (action) => SizedBox(
                  width: itemWidth,
                  child: InstructorQuickActionCard(
                    icon: action.icon,
                    label: action.label,
                    onTap: action.onTap,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class InstructorQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const InstructorQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return GestureDetector(
      onTap: onTap,
      child: InstructorSurfaceCard(
        radius: 14,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 12 : 14,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xffe8f7f7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact ? 22 : 24,
                color: const Color(0xff0bb4b1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 11 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructorCourseSummaryCard extends StatelessWidget {
  final String primaryCode;
  final String primaryTitle;
  final String secondaryCode;
  final String secondaryTitle;

  const InstructorCourseSummaryCard({
    super.key,
    required this.primaryCode,
    required this.primaryTitle,
    required this.secondaryCode,
    required this.secondaryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return InstructorSurfaceCard(
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourseEntry(code: primaryCode, title: primaryTitle),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CourseEntry(
                        code: secondaryCode,
                        title: secondaryTitle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff0bb4b1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CourseEntry(code: primaryCode, title: primaryTitle),
                ),
                Container(height: 45, width: 1, color: Colors.grey.shade200),
                const SizedBox(width: 12),
                Expanded(
                  child: _CourseEntry(
                    code: secondaryCode,
                    title: secondaryTitle,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
    );
  }
}

class _CourseEntry extends StatelessWidget {
  final String code;
  final String title;

  const _CourseEntry({
    required this.code,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xff0bb4b1),
          ),
        ),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
