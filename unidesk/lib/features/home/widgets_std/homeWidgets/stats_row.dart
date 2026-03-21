import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
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
    final credits = (profile['credits'] ?? 0).toString();

    final percentage = profile['credits'] / profile['totalHours'] * 100;

    final gpa = (profile['gpa'] ?? 0).toString();

    final stats = [
      StatItem(
        value: '${percentage.toStringAsFixed(1)}%',
        label: lang.translate('completion_percentage'),
      ),
      StatItem(value: credits, label: lang.translate('credits')),
      StatItem(value: gpa, label: lang.translate('gpa')),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingHorizontal,
        vertical: AppSizes.spacingSmall,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
       child: IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch, // stretch all to same height
    children: stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isLast = index == stats.length - 1;

      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: !isLast
                ? const Border(
                    right: BorderSide(color: Colors.white24, width: 1),
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 push value to top, label to bottom
            children: [
              Text(
                stat.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
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
        ),
      );
    }).toList(),
  ),
),
      ),
    );
  }
}
  
