import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../language/langProvider.dart';

class StatItem {
  final String value;
  final String label;

  const StatItem({required this.value, required this.label});
}

class StatsRow extends StatelessWidget {
  final Map<String, dynamic> profile;

  const StatsRow({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    final credits =
        (profile['credits'] ?? profile['creditsEarned'] ?? 0).toString();

    final totalHours = profile['totalHours'] ?? profile['totalCredits'] ?? 0;
    final completionPercent = profile['completionPercentage'] ??
        (totalHours != 0 ? (profile['credits'] ?? 0) / totalHours * 100 : 0);
    final gpa = (profile['gpa'] ?? profile['cumulativeGpa'] ?? 0).toString();

    final stats = [
      StatItem(
        value: '${(completionPercent as num).toStringAsFixed(1)}%',
        label: lang.translate('completion_percentage'),
      ),
      StatItem(value: credits, label: lang.translate('credits')),
      StatItem(value: gpa, label: lang.translate('gpa')),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = ResponsiveLayout.isCompact(context);
        final spacing = compact ? 10.0 : 0.0;
        final columns = ResponsiveLayout.columnsForWidth(
          constraints.maxWidth,
          compact: 1,
          medium: 3,
          wide: 3,
        );
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : constraints.maxWidth / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: columns == 1 ? itemWidth : itemWidth - 1,
                  child: _StatCard(stat: stat, compact: compact),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatItem stat;
  final bool compact;

  const _StatCard({
    required this.stat,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 14 : 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
