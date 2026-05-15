import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../language/langProvider.dart';

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
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LangProvider>(context);
    const spacing = 10.0;

    final actions = [
      QuickActionItem(
        icon: Icons.payment_outlined,
        label: lang.translate('electronic_payment'),
        onTap: () {},
      ),
      QuickActionItem(
        icon: Icons.headset_mic_outlined,
        label: lang.translate('technical_support'),
        onTap: () => context.push('/technical-support'),
      ),
      QuickActionItem(
        icon: Icons.book_outlined,
        label: lang.translate('current_semester'),
        onTap: () => context.push('/current-semester'),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(child: _QuickActionCard(item: actions[i])),
          if (i != actions.length - 1) const SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickActionItem item;

  const _QuickActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final compact = ResponsiveLayout.isCompact(context);

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 12 : AppSizes.spacingSmall,
          horizontal: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.white, size: compact ? 22 : 25),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
