import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../language/langProvider.dart';

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class QuickActionsRow extends StatelessWidget {
    final List<Map<String, dynamic>> courses;  // passing the courses from home to quickactions to use it in the current semester action
  const QuickActionsRow({required this.courses, super.key});
 
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);

    final actions = [
      QuickActionItem(
        icon: Icons.payment_outlined,
        label: lang.translate('electronic_payment'),
        onTap: () {},
      ),
      QuickActionItem(
        icon: Icons.headset_mic_outlined,
        label: lang.translate('technical_support'),
        onTap: () {},
      ),
      QuickActionItem(
        icon: Icons.book_outlined,
        label: lang.translate('current_semester'),

        onTap: () {}, 
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingHorizontal,
        vertical: AppSizes.spacingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions
            .map((action) => _QuickActionCard(item: action))
            .toList(),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickActionItem item;

  const _QuickActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacingSmall,
          horizontal: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.white, size: 25),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
