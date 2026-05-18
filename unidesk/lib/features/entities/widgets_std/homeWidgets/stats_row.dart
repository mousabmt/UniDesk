import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../language/langProvider.dart';

class StatItem {
  final String value;
  final String label;
  const StatItem({required this.value, required this.label});
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String _formatGpa(dynamic value) =>
    (_asDouble(value) ?? 0.0).toStringAsFixed(2);

class StatsRow extends StatelessWidget {
  final Map<String, dynamic> profile;

  const StatsRow({super.key, required this.profile});

  List<StatItem> _buildStats(LangProvider lang) {
    final rawCredits = profile['credits'] ?? profile['creditsEarned'] ?? 0;
    final totalHours = _asDouble(profile['totalHours'] ?? profile['totalCredits']);
    final completedCredits = _asDouble(rawCredits) ?? 0.0;

    final completionPercent = _asDouble(
          profile['completionPercentage'] ??
              (totalHours != null && totalHours != 0
                  ? (completedCredits / totalHours) * 100
                  : 0.0),
        ) ??
        0.0;

    return [
      StatItem(
        value: '${completionPercent.toStringAsFixed(1)}%',
        label: lang.translate('completion_percentage'),
      ),
      StatItem(
        value: rawCredits.toString(),
        label: lang.translate('credits'),
      ),
      StatItem(
        value: _formatGpa(profile['gpa'] ?? profile['cumulativeGpa']),
        label: lang.translate('gpa'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final stats = _buildStats(lang);

    return Material(
      color: AppColors.primaryBlue,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: List.generate(stats.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Divider
              return Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.white.withOpacity(0.2),
              );
            }

            final statIndex = index ~/ 2;
            final stat = stats[statIndex];

            return Expanded(
              child: _StatItemContent(stat: stat),
            );
          }),
        ),
      ),
    );
  }
}

class _StatItemContent extends StatelessWidget {
  final StatItem stat;

  const _StatItemContent({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stat.label}: ${stat.value}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stat.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}